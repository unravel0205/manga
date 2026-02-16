# Supabase Storage セットアップガイド

高品質な漫画画像を保存するため、Supabase Storageバケットを作成します。

## ステップ1: Supabase Dashboardにアクセス

1. https://supabase.com にアクセス
2. ログイン
3. プロジェクト **twhhrgcksstikdoyroto** を選択

## ステップ2: Storageバケットを作成

1. 左サイドバーから **Storage** をクリック
2. **New bucket** ボタンをクリック
3. 以下を入力:
   - **Name**: `manga-images`
   - **Public bucket**: ✅ チェックを入れる（画像を公開URLで参照できるようにする）
4. **Create bucket** をクリック

## ステップ3: ポリシーを設定

1. 作成した **manga-images** バケットをクリック
2. **Policies** タブを開く
3. **New policy** をクリック

### ポリシー1: 読み取り（全員）

```sql
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'manga-images' );
```

または、UIで:
- Policy name: `Public Access`
- Allowed operation: `SELECT`
- Target roles: `public`

### ポリシー2: アップロード（認証済みユーザー）

```sql
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'manga-images'
  AND auth.role() = 'authenticated'
);
```

または、UIで:
- Policy name: `Authenticated users can upload`
- Allowed operation: `INSERT`
- Target roles: `authenticated`

### ポリシー3: 削除（所有者のみ）

```sql
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'manga-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

または、UIで:
- Policy name: `Users can delete own images`
- Allowed operation: `DELETE`
- Policy definition: カスタムSQL（上記SQLを使用）

## ステップ4: 確認

1. **Storage** → **manga-images** が表示されていることを確認
2. バケットの設定アイコン（歯車）をクリック
3. **Public** が有効になっていることを確認

## 完了！

これで高品質な画像を保存できるようになりました。

## 容量と制限

**無料プラン:**
- Storage容量: 1GB
- 転送量: 2GB/月

**保存可能枚数（概算）:**
- 4K高品質画像（1-3MB）: 約300-1000枚
- 圧縮なし、元の品質を維持

## トラブルシューティング

### エラー: "Bucket already exists"

すでに作成されています。問題ありません。

### 画像がアップロードできない

1. ポリシーが正しく設定されているか確認
2. ログインしているか確認
3. ブラウザのコンソールでエラーを確認

### 画像が表示されない

1. バケットが **Public** になっているか確認
2. 読み取りポリシーが設定されているか確認

---

**次のステップ:** アプリで漫画を生成して、画像が保存されることを確認してください。
