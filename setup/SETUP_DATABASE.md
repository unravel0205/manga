# データベースセットアップガイド

漫画生成ツールで履歴保存機能を有効にするため、Supabaseデータベースにテーブルを作成します。

## ステップ1: Supabase Dashboardにアクセス

1. https://supabase.com にアクセス
2. ログイン
3. プロジェクト **twhhrgcksstikdoyroto** を選択

## ステップ2: SQLエディタを開く

1. 左サイドバーから **SQL Editor** をクリック
2. **+ New query** ボタンをクリック

## ステップ3: SQLを実行

以下のSQLをコピーして、SQLエディタに貼り付けます。

```sql
-- 漫画履歴テーブルの作成
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

-- ポリシー: ユーザーは自分の漫画のみ読み取り可能
CREATE POLICY "Users can read own mangas"
  ON mangas FOR SELECT
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分の漫画のみ挿入可能
CREATE POLICY "Users can insert own mangas"
  ON mangas FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ポリシー: ユーザーは自分の漫画のみ削除可能
CREATE POLICY "Users can delete own mangas"
  ON mangas FOR DELETE
  USING (auth.uid() = user_id);
```

## ステップ4: SQL実行

1. **RUN** ボタン（または Ctrl+Enter / Cmd+Enter）をクリック
2. 成功メッセージが表示されることを確認

## ステップ5: テーブル確認

1. 左サイドバーから **Table Editor** をクリック
2. **mangas** テーブルが表示されていることを確認

## 完了！

これで履歴保存機能が有効になりました。

## 機能

- ログインユーザーごとに履歴を保存
- 最新10件を自動表示
- デバイス間で履歴を共有
- 実質無制限の保存容量

## トラブルシューティング

### エラー: "relation "mangas" already exists"

すでにテーブルが作成されています。問題ありません。

### エラー: "permission denied"

Supabaseプロジェクトの権限を確認してください。プロジェクトオーナーである必要があります。

### テーブルが表示されない

1. ブラウザを更新
2. Table Editor → 右上の更新ボタンをクリック
3. 左サイドバーの **Tables** をクリック

---

**サポート:** 問題が解決しない場合は、Supabase Dashboardの Logs セクションでエラーログを確認してください。
