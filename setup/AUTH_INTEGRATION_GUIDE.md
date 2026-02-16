# 認証機能統合ガイド

このガイドでは、既存の漫画生成ツールにSupabase認証とユーザー名登録機能を統合する手順を説明します。

## 前提条件

- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) の手順を完了していること
- SUPABASE_URLとSUPABASE_ANON_KEYを取得済みであること

## 実装概要

### 主な変更点

1. **Supabase SDKの追加**
2. **ログイン/サインアップ画面の追加**
3. **ユーザー名フィールドの追加**
4. **認証状態管理**
5. **データ保存先をlocalStorageからSupabaseへ移行**

## 実装手順

### 1. Supabase SDKの読み込み

`index.html`の`<head>`セクションに以下を追加：

```html
<!-- Supabase SDK -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

### 2. Supabase初期化コード

`<script>`タグ内の先頭に以下を追加：

```javascript
// Supabase設定（実際の値に置き換えてください）
const SUPABASE_URL = 'あなたのSUPABASE_URL';
const SUPABASE_ANON_KEY = 'あなたのSUPABASE_ANON_KEY';

// Supabaseクライアント初期化
const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

### 3. 認証コンポーネントの追加

#### 3-1. ログイン/サインアップフォーム

```javascript
function AuthForm() {
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSignUp() {
    setLoading(true);
    setError('');

    const { data, error } = await supabase.auth.signUp({
      email: email,
      password: password,
      options: {
        data: {
          full_name: fullName
        }
      }
    });

    if (error) {
      setError(error.message);
    } else {
      alert('登録完了！ログインしてください。');
      setIsSignUp(false);
    }

    setLoading(false);
  }

  async function handleSignIn() {
    setLoading(true);
    setError('');

    const { data, error } = await supabase.auth.signInWithPassword({
      email: email,
      password: password
    });

    if (error) {
      setError(error.message);
    }

    setLoading(false);
  }

  return html`
    <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <div class="bg-white rounded-2xl shadow-xl p-8 w-full max-w-md">
        <h1 class="text-3xl font-bold text-center mb-2 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
          漫画生成ツール
        </h1>
        <p class="text-center text-gray-600 mb-8">
          ${isSignUp ? '新規登録' : 'ログイン'}
        </p>

        ${error && html`
          <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
            ${error}
          </div>
        `}

        <div class="space-y-4">
          ${isSignUp && html`
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">お名前</label>
              <input
                type="text"
                value=${fullName}
                onInput=${(e) => setFullName(e.target.value)}
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="山田太郎"
                required
              />
            </div>
          `}

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">メールアドレス</label>
            <input
              type="email"
              value=${email}
              onInput=${(e) => setEmail(e.target.value)}
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="example@email.com"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">パスワード</label>
            <input
              type="password"
              value=${password}
              onInput=${(e) => setPassword(e.target.value)}
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="8文字以上"
              required
            />
          </div>

          <button
            onClick=${isSignUp ? handleSignUp : handleSignIn}
            disabled=${loading}
            class="w-full py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg font-semibold hover:from-blue-700 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed transition"
          >
            ${loading ? '処理中...' : (isSignUp ? '登録する' : 'ログイン')}
          </button>

          <button
            onClick=${() => setIsSignUp(!isSignUp)}
            class="w-full text-sm text-gray-600 hover:text-gray-800"
          >
            ${isSignUp ? 'すでにアカウントをお持ちの方' : 'アカウントをお持ちでない方'}
          </button>
        </div>
      </div>
    </div>
  `;
}
```

### 4. メインアプリケーションの修正

#### 4-1. 認証状態の管理

```javascript
function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // 認証状態の監視
  useEffect(() => {
    // 現在のセッションを確認
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null);
      setLoading(false);
    });

    // 認証状態の変更を監視
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    return () => subscription.unsubscribe();
  }, []);

  // ログアウト処理
  async function handleSignOut() {
    await supabase.auth.signOut();
  }

  if (loading) {
    return html`
      <div class="min-h-screen flex items-center justify-center">
        <div class="text-xl text-gray-600">読み込み中...</div>
      </div>
    `;
  }

  // 未ログインの場合は認証画面を表示
  if (!user) {
    return html`<${AuthForm} />`;
  }

  // ログイン済みの場合は既存のアプリを表示
  return html`
    <div class="min-h-screen bg-gray-50">
      <!-- ヘッダー -->
      <header class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
          <h1 class="text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            漫画生成ツール
          </h1>
          <div class="flex items-center gap-4">
            <span class="text-sm text-gray-600">
              ${user.user_metadata?.full_name || user.email}
            </span>
            <button
              onClick=${handleSignOut}
              class="px-4 py-2 text-sm text-gray-700 hover:text-gray-900 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              ログアウト
            </button>
          </div>
        </div>
      </header>

      <!-- 既存のアプリケーション -->
      <main class="max-w-7xl mx-auto px-4 py-8">
        ${/* 既存のコンテンツをここに配置 */}
      </main>
    </div>
  `;
}
```

### 5. データ保存の変更

#### 5-1. 漫画保存処理（localStorage → Supabase）

**変更前:**
```javascript
localStorage.setItem('manga_history', JSON.stringify(histArr));
```

**変更後:**
```javascript
// Supabaseに保存
const { data, error } = await supabase
  .from('mangas')
  .insert([{
    user_id: user.id,
    image_url: compressedImg,
    story: story,
    style_id: style,
    style_name: styleName,
    settings: {
      speech: speech,
      model: model,
      modelName: modelName
    }
  }]);

if (error) {
  console.error('保存エラー:', error);
  alert('保存に失敗しました');
}
```

#### 5-2. 履歴読み込み処理

**変更前:**
```javascript
const savedHist = localStorage.getItem('manga_history');
const histArr = savedHist ? JSON.parse(savedHist) : [];
```

**変更後:**
```javascript
const { data, error } = await supabase
  .from('mangas')
  .select('*')
  .eq('user_id', user.id)
  .order('created_at', { ascending: false })
  .limit(10);

if (error) {
  console.error('読み込みエラー:', error);
} else {
  setHistory(data || []);
}
```

### 6. 画像アップロード（Supabase Storage）

```javascript
async function uploadImageToSupabase(base64Image, userId) {
  // Base64をBlobに変換
  const base64Data = base64Image.split(',')[1];
  const byteCharacters = atob(base64Data);
  const byteNumbers = new Array(byteCharacters.length);
  for (let i = 0; i < byteCharacters.length; i++) {
    byteNumbers[i] = byteCharacters.charCodeAt(i);
  }
  const byteArray = new Uint8Array(byteNumbers);
  const blob = new Blob([byteArray], { type: 'image/png' });

  // ファイル名生成
  const fileName = `${userId}/${Date.now()}.png`;

  // Supabase Storageにアップロード
  const { data, error } = await supabase.storage
    .from('manga-images')
    .upload(fileName, blob, {
      contentType: 'image/png',
      cacheControl: '3600'
    });

  if (error) {
    console.error('アップロードエラー:', error);
    return null;
  }

  // 公開URLを取得
  const { data: { publicUrl } } = supabase.storage
    .from('manga-images')
    .getPublicUrl(fileName);

  return publicUrl;
}
```

## セキュリティ注意事項

### ⚠️ APIキーの取り扱い

```javascript
// ❌ NG: APIキーをlocalStorageに保存
localStorage.setItem('manga_api_key', apiKey);

// ✅ OK: ユーザーごとにセッション内でのみ管理
const [apiKey, setApiKey] = useState('');
// セッション終了時に自動削除
```

### APIキー入力フォーム

```javascript
function ApiKeyInput() {
  const [apiKey, setApiKey] = useState('');
  const [saved, setSaved] = useState(false);

  return html`
    <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-4">
      <h3 class="font-semibold text-yellow-800 mb-2">Claude APIキーの設定</h3>
      <p class="text-sm text-yellow-700 mb-3">
        ⚠️ APIキーは安全に管理してください。他人と共有しないでください。
      </p>
      <input
        type="password"
        value=${apiKey}
        onInput=${(e) => setApiKey(e.target.value)}
        placeholder="sk-ant-..."
        class="w-full px-3 py-2 border rounded-lg mb-2"
      />
      <button
        onClick=${() => setSaved(true)}
        class="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700"
      >
        保存
      </button>
    </div>
  `;
}
```

## テスト手順

1. **ローカルでテスト**
   - `python3 -m http.server 8000`
   - http://localhost:8000 にアクセス

2. **新規登録テスト**
   - 名前、メール、パスワードを入力
   - 登録ボタンをクリック
   - Supabase Dashboardでユーザー確認

3. **ログインテスト**
   - 登録したメール・パスワードでログイン
   - ユーザー名が表示されることを確認

4. **漫画生成テスト**
   - 漫画を生成
   - Supabase Dashboardのmangasテーブルでデータ確認
   - Storageで画像確認

5. **ログアウト・再ログインテスト**
   - ログアウト
   - 再ログイン
   - 履歴が保持されていることを確認

## 次のステップ

✅ 認証機能統合完了後：
1. Netlifyにデプロイ
2. 本番環境でのテスト
3. ユーザーフィードバック収集

---

**サポートが必要な場合:**
- Supabase Dashboard でエラーログを確認
- ブラウザのコンソールでエラーを確認
