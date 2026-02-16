# Supabase セットアップガイド

このドキュメントでは、漫画生成ツールにSupabase認証とデータベースを統合する手順を説明します。

## 1. Supabaseプロジェクトの作成

### 1-1. アカウント作成
1. https://supabase.com にアクセス
2. 「Start your project」をクリック
3. GitHubアカウントでサインアップ（推奨）

### 1-2. 新規プロジェクト作成
1. ダッシュボードで「New Project」をクリック
2. 以下を入力：
   - **Name**: `manga-generator`（任意）
   - **Database Password**: 強力なパスワードを設定（必ずメモ）
   - **Region**: `Northeast Asia (Tokyo)`（日本向けの場合）
3. 「Create new project」をクリック
4. プロジェクト作成完了まで約2分待機

## 2. プロジェクト設定値の取得

### 2-1. API認証情報の確認
1. 左サイドバーの「Settings」→「API」をクリック
2. 以下の値をコピー（後で使用）:
   ```
   Project URL: https://xxxxxxxxxx.supabase.co
   anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

## 3. データベーステーブルの作成

### 3-1. SQLエディタでテーブル作成
1. 左サイドバーの「SQL Editor」をクリック
2. 「New query」をクリック
3. 以下のSQLを貼り付けて実行：

```sql
-- マンガ保存用テーブル
CREATE TABLE mangas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  story TEXT,
  style_id INTEGER,
  style_name TEXT,
  settings JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成（検索高速化）
CREATE INDEX idx_mangas_user_id ON mangas(user_id);
CREATE INDEX idx_mangas_created_at ON mangas(created_at DESC);

-- Row Level Security (RLS) を有効化
ALTER TABLE mangas ENABLE ROW LEVEL SECURITY;

-- ポリシー: ユーザーは自分のデータのみ読み取り可能
CREATE POLICY "Users can read own mangas"
  ON mangas FOR SELECT
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のデータのみ挿入可能
CREATE POLICY "Users can insert own mangas"
  ON mangas FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のデータのみ削除可能
CREATE POLICY "Users can delete own mangas"
  ON mangas FOR DELETE
  USING (auth.uid() = user_id);
```

4. 「Run」ボタンをクリック
5. 成功メッセージが表示されることを確認

### 3-2. テーブル確認
1. 左サイドバーの「Table Editor」をクリック
2. `mangas`テーブルが表示されることを確認

## 4. 認証設定

### 4-1. Email認証の設定
1. 左サイドバーの「Authentication」→「Providers」をクリック
2. 「Email」が有効になっていることを確認
3. 必要に応じて以下を設定：
   - **Confirm email**: ON（メール確認を必須にする場合）
   - **Secure email change**: ON（推奨）

### 4-2. Google認証の追加（オプション）
1. 「Google」プロバイダーをクリック
2. 「Enable Sign in with Google」をON
3. Google Cloud Consoleで認証情報を取得：
   - https://console.cloud.google.com
   - OAuth 2.0クライアントIDを作成
   - Client IDとClient Secretをコピー
4. SupabaseにClient IDとSecretを貼り付け
5. 「Save」をクリック

## 5. Storageバケットの作成（画像保存用）

### 5-1. バケット作成
1. 左サイドバーの「Storage」をクリック
2. 「Create a new bucket」をクリック
3. 以下を入力：
   - **Name**: `manga-images`
   - **Public bucket**: ON
4. 「Create bucket」をクリック

### 5-2. Storage ポリシー設定
1. 作成した`manga-images`バケットをクリック
2. 「Policies」タブをクリック
3. 「New Policy」をクリック
4. 以下のポリシーを追加：

**アップロードポリシー:**
```sql
CREATE POLICY "Users can upload own images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'manga-images' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

**読み取りポリシー:**
```sql
CREATE POLICY "Anyone can view images"
ON storage.objects FOR SELECT
USING (bucket_id = 'manga-images');
```

**削除ポリシー:**
```sql
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'manga-images' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

## 6. アプリケーションへの統合

### 6-1. 設定値を控える
以下の値を控えておきます：
```
SUPABASE_URL=https://xxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 6-2. index.htmlに設定を追加
index.htmlの先頭に以下を追加します：
```javascript
const SUPABASE_URL = 'あなたのSUPABASE_URL';
const SUPABASE_ANON_KEY = 'あなたのSUPABASE_ANON_KEY';
```

## 7. 動作確認

### 7-1. 認証テスト
1. アプリケーションを開く
2. 新規登録を試す
3. Supabase Dashboard → Authentication → Users で登録ユーザーが表示されることを確認

### 7-2. データ保存テスト
1. ログイン後、漫画を生成
2. Supabase Dashboard → Table Editor → mangas で保存データを確認

### 7-3. Storage確認
1. 画像が生成されたことを確認
2. Supabase Dashboard → Storage → manga-images でアップロードされた画像を確認

## トラブルシューティング

### エラー: "Invalid API key"
- SUPABASE_URLとSUPABASE_ANON_KEYが正しいか確認
- 値にスペースや改行が含まれていないか確認

### エラー: "Row level security policy violated"
- RLSポリシーが正しく設定されているか確認
- SQL Editorで再度ポリシーを実行

### ユーザー登録ができない
- Authentication → Providers でEmailが有効か確認
- メール確認が必須の場合、確認メールが届いているか確認

## 次のステップ

セットアップ完了後、以下を実施：
1. ✅ アプリケーションのテスト
2. ✅ Netlifyへのデプロイ
3. ✅ 本番環境での動作確認

---

**重要**: Database Passwordは絶対に公開しないでください。
