# キャラクター作成機能 実装プラン

## 実装状況

✅ 完了:
- character_sheetsテーブルSQL作成
- セットアップガイド作成
- キャラクターシートプロンプトテンプレート作成
- index.htmlに必要な状態変数追加 (s73-s83)

## 次のステップ

### Phase 1: キャラクター作成タブUI (進行中)

実装箇所: `/Users/okawakazuya/Downloads/よく使う/Claude/tools/manga/index.html`

#### 1.1 タブナビゲーション追加
行2650付近（メインコンテンツエリアの開始）にタブナビゲーションを追加:

```html
<div class="mb-6 border-b border-gray-200">
  <nav class="flex gap-6">
    <button
      onClick={() => setActiveTab('manga')}
      class={`pb-3 px-2 border-b-2 ${activeTab === 'manga' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
    >
      漫画生成
    </button>
    <button
      onClick={() => setActiveTab('character')}
      class={`pb-3 px-2 border-b-2 ${activeTab === 'character' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
    >
      キャラクター作成
    </button>
    <button
      onClick={() => setActiveTab('history')}
      class={`pb-3 px-2 border-b-2 ${activeTab === 'history' ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
    >
      生成履歴
    </button>
  </nav>
</div>
```

#### 1.2 タブコンテンツの条件分岐
既存の漫画生成UIをactiveTab === 'manga'で囲む
キャラクター作成UIをactiveTab === 'character'で表示

#### 1.3 キャラクター作成フォーム
```html
{activeTab === 'character' && html`
  <div class="max-w-2xl mx-auto">
    <h2 class="text-2xl font-bold mb-6">キャラクターシート作成</h2>

    <!-- 保存済みキャラクター表示 -->
    <div class="mb-6 p-4 bg-blue-50 rounded-lg">
      <div class="flex items-center justify-between">
        <div>
          <span class="font-semibold">💾 保存済みキャラクター</span>
          <span class="ml-2 text-gray-600">(${characterSheets.length})</span>
        </div>
        <button onClick={() => setShowCharSheetList(true)} class="text-blue-600 hover:text-blue-700">
          一覧を見る ›
        </button>
      </div>
    </div>

    <!-- 作成フォーム -->
    <div class="space-y-6">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
          キャラクター名 *
        </label>
        <input
          type="text"
          value={charSheetName}
          onInput={(e) => setCharSheetName(e.target.value)}
          placeholder="例: 山田太郎"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
          キャラクター説明 *
        </label>
        <textarea
          value={charSheetDesc}
          onInput={(e) => setCharSheetDesc(e.target.value)}
          placeholder="例:\n25歳男性、短い黒髪、茶色い瞳\nグレーのスーツに青いネクタイ\n優しい笑顔、細身の体型"
          rows="5"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg"
        />
        <div class="text-xs text-gray-500 mt-1">
          {charSheetDesc.length} / 500文字
        </div>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
          ベース画像（オプション）
        </label>
        <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
          <input
            type="file"
            ref={charSheetFileRef}
            onChange={handleCharSheetImageUpload}
            accept="image/*"
            class="hidden"
          />
          <button
            onClick={() => charSheetFileRef.current?.click()}
            class="text-blue-600 hover:text-blue-700"
          >
            📁 ファイルを選択
          </button>
          <p class="text-xs text-gray-500 mt-2">
            PNG, JPG, WEBP (最大10MB)
          </p>
        </div>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
          アートスタイル *
        </label>
        <select
          value={style}
          onChange={(e) => setStyle(Number(e.target.value))}
          class="w-full px-4 py-2 border border-gray-300 rounded-lg"
        >
          {STYLES.map(s => html`<option value={s.id}>{s.title}</option>`)}
        </select>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
          解像度
        </label>
        <div class="flex gap-4">
          {['standard', '2k', '4k'].map(m => html`
            <label class="flex items-center">
              <input
                type="radio"
                checked={model === m}
                onChange={() => setModel(m)}
                class="mr-2"
              />
              <span class="text-sm">{m === 'standard' ? '標準' : m === '2k' ? '高品質 2K' : '超高品質 4K'}</span>
            </label>
          `)}
        </div>
      </div>

      <button
        onClick={generateCharacterSheet}
        disabled={!charSheetName || !charSheetDesc || isGenCharSheet}
        class="w-full py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
      >
        🎨 キャラクターシート生成（約30秒）
      </button>
    </div>
  </div>
`}
```

### Phase 2: キャラクターシート生成ロジック

#### 2.1 generateCharacterSheet関数追加

```javascript
async function generateCharacterSheet() {
  if (!charSheetName || !charSheetDesc) {
    alert('キャラクター名と説明を入力してください');
    return;
  }

  setIsGenCharSheet(true);
  setError('');

  try {
    // 1. テンプレートプロンプト読み込み
    const promptTemplate = await fetch('./prompts/キャラクターシート_image.txt').then(r => r.text());

    // 2. 変数置換
    const selectedStyle = STYLES.find(s => s.id === style);
    const prompt = promptTemplate
      .replace(/\{\{CHARACTER_DESCRIPTION\}\}/g, charSheetDesc)
      .replace(/\{\{STYLE_PROMPT\}\}/g, selectedStyle.prompt);

    // 3. Gemini API呼び出し
    const parts = [{ text: prompt }];

    // テンプレート画像を参照に追加
    const templateImageResponse = await fetch('/キャラクターシート_テンプレート.jpeg');
    const templateBlob = await templateImageResponse.blob();
    const templateBase64 = await blobToBase64(templateBlob);
    parts.push({
      inlineData: {
        mimeType: 'image/jpeg',
        data: templateBase64.split(',')[1]
      }
    });

    // ベース画像があれば追加
    if (charSheetBaseImg) {
      parts.push({
        inlineData: {
          mimeType: 'image/jpeg',
          data: charSheetBaseImg.split(',')[1]
        }
      });
    }

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODELS.find(m => m.id === model).name}:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts }],
          generationConfig: {
            responseModalities: ['IMAGE'],
            temperature: 0.3,
            topP: 0.8,
            topK: 30
          }
        })
      }
    );

    const data = await response.json();
    const imageData = data.candidates[0].content.parts.find(p => p.inlineData)?.inlineData.data;

    if (!imageData) throw new Error('画像生成に失敗しました');

    const generatedImage = `data:image/jpeg;base64,${imageData}`;
    setGeneratedCharSheet(generatedImage);

  } catch (err) {
    setError('キャラクターシート生成エラー: ' + err.message);
  } finally {
    setIsGenCharSheet(false);
  }
}
```

#### 2.2 Supabase保存関数

```javascript
async function saveCharacterSheet() {
  if (!generatedCharSheet) return;

  try {
    // 1. Storage にアップロード
    const blob = await fetch(generatedCharSheet).then(r => r.blob());
    const fileName = `character_sheets/${user.id}/${Date.now()}.png`;

    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('manga-images')
      .upload(fileName, blob, {
        contentType: 'image/png',
        cacheControl: '3600'
      });

    if (uploadError) throw uploadError;

    const { data: urlData } = supabase.storage
      .from('manga-images')
      .getPublicUrl(fileName);

    // 2. Database に保存
    const selectedStyle = STYLES.find(s => s.id === style);
    const { data, error } = await supabase
      .from('character_sheets')
      .insert({
        user_id: user.id,
        name: charSheetName,
        description: charSheetDesc,
        style_id: style,
        style_name: selectedStyle.title,
        sheet_image_url: urlData.publicUrl,
        base_image_url: charSheetBaseImg
      })
      .select();

    if (error) throw error;

    // 3. ローカル状態更新
    setCharacterSheets([data[0], ...characterSheets]);
    setGeneratedCharSheet(null);
    setCharSheetName('');
    setCharSheetDesc('');
    setCharSheetBaseImg(null);

    alert('キャラクターシートを保存しました！');

  } catch (err) {
    setError('保存エラー: ' + err.message);
  }
}
```

### Phase 3: キャラクター一覧と管理機能

実装箇所: モーダルコンポーネント

#### 3.1 キャラクター一覧モーダル
#### 3.2 編集機能
#### 3.3 削除機能

### Phase 4: 漫画生成との連携

実装箇所: 漫画生成フォーム

#### 4.1 キャラクター選択ドロップダウン追加
#### 4.2 選択キャラクターの参照画像として使用

## 必要なファイル

✅ 作成済み:
- `CHARACTER_SHEETS_TABLE_SETUP.sql`
- `SETUP_CHARACTER_SHEETS.md`
- `prompts/キャラクターシート_image.txt`

⏳ 既存ファイル修正:
- `index.html` (大規模な変更)

## 次のアクション

1. index.htmlにタブナビゲーションを追加
2. キャラクター作成フォームUIを追加
3. 生成ロジックを実装
4. Supabase保存機能を実装
5. 一覧表示機能を実装
6. 漫画生成との連携を実装

## 注意事項

- index.htmlは3336行と非常に大きいため、段階的に変更
- 既存のコードを壊さないよう慎重に追加
- ユーザーにはSupabaseのテーブル作成が必要であることを通知
