# キャラクターシート機能セットアップガイド

キャラクター作成機能を有効にするため、Supabaseデータベースにテーブルを作成します。

## ステップ1: Supabase Dashboardにアクセス

1. https://supabase.com にアクセス
2. ログイン
3. プロジェクト **twhhrgcksstikdoyroto** を選択

## ステップ2: SQLエディタを開く

1. 左サイドバーから **SQL Editor** をクリック
2. **+ New query** ボタンをクリック

## ステップ3: SQLを実行

`CHARACTER_SHEETS_TABLE_SETUP.sql` ファイルの内容をコピーして、SQLエディタに貼り付けます。

または、以下のSQLを直接コピー:

```sql
-- キャラクターシートテーブルの作成
CREATE TABLE character_sheets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  style_id INTEGER,
  style_name TEXT,
  sheet_image_url TEXT NOT NULL,
  base_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成（検索高速化）
CREATE INDEX idx_character_sheets_user_id ON character_sheets(user_id);
CREATE INDEX idx_character_sheets_created_at ON character_sheets(created_at DESC);

-- Row Level Security (RLS) を有効化
ALTER TABLE character_sheets ENABLE ROW LEVEL SECURITY;

-- ポリシー: ユーザーは自分のキャラクターシートのみ読み取り可能
CREATE POLICY "Users can read own character sheets"
  ON character_sheets FOR SELECT
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のキャラクターシートのみ挿入可能
CREATE POLICY "Users can insert own character sheets"
  ON character_sheets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のキャラクターシートのみ更新可能
CREATE POLICY "Users can update own character sheets"
  ON character_sheets FOR UPDATE
  USING (auth.uid() = user_id);

-- ポリシー: ユーザーは自分のキャラクターシートのみ削除可能
CREATE POLICY "Users can delete own character sheets"
  ON character_sheets FOR DELETE
  USING (auth.uid() = user_id);
```

## ステップ4: SQL実行

1. **RUN** ボタン（または Ctrl+Enter / Cmd+Enter）をクリック
2. 成功メッセージが表示されることを確認

## ステップ5: テーブル確認

1. 左サイドバーから **Table Editor** をクリック
2. **character_sheets** テーブルが表示されていることを確認

## 完了！

これでキャラクター作成機能が有効になりました。

## 機能

- ログインユーザーごとにキャラクターシートを保存
- 5つのバリエーション（Neutral, Smile, Front, Side, Back）を1枚の画像に生成
- 漫画生成時に参照画像として使用可能
- 編集・削除・再生成機能

## トラブルシューティング

### エラー: "relation \"character_sheets\" already exists"

すでにテーブルが作成されています。問題ありません。

### エラー: "permission denied"

Supabaseプロジェクトの権限を確認してください。プロジェクトオーナーである必要があります。

### テーブルが表示されない

1. ブラウザを更新
2. Table Editor → 右上の更新ボタンをクリック
3. 左サイドバーの **Tables** をクリック

---

**次のステップ:** アプリでキャラクターを作成して、漫画生成で使用できることを確認してください。
