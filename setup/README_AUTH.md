# Supabase認証統合 - 実装ガイド

このガイドに従って、漫画生成ツールにユーザー認証とデータベース機能を追加できます。

## 📋 実装ファイル一覧

```
manga/
├── index.html                    # 既存のアプリ（バックアップ済み）
├── index_backup.html             # バックアップ
├── auth_demo.html                # 認証機能デモ（テスト用）
├── SUPABASE_SETUP.md            # Supabase初期設定ガイド
├── AUTH_INTEGRATION_GUIDE.md    # 認証統合の詳細ガイド
└── README_AUTH.md               # このファイル
```

## 🚀 クイックスタート（3ステップ）

### ステップ1: Supabaseプロジェクトを作成

1. **[SUPABASE_SETUP.md](./SUPABASE_SETUP.md)** を開く
2. 手順に従ってSupabaseプロジェクトを作成
3. 以下の2つの値を控える：
   - `SUPABASE_URL`（例: https://xxxxx.supabase.co）
   - `SUPABASE_ANON_KEY`（例: eyJhbGciOi...）

### ステップ2: 認証デモで動作確認

1. **auth_demo.html** をテキストエディタで開く

2. 8-9行目を自分の値に置き換える：
   ```javascript
   const SUPABASE_URL = 'あなたのSUPABASE_URL';
   const SUPABASE_ANON_KEY = 'あなたのSUPABASE_ANON_KEY';
   ```

3. ブラウザで **auth_demo.html** を開く

4. 新規登録をテスト：
   - 名前を入力
   - メールアドレスを入力
   - パスワードを入力（8文字以上）
   - 「登録する」をクリック

5. ログインをテスト：
   - 登録したメール・パスワードでログイン
   - ダッシュボードが表示されることを確認

6. Supabase Dashboard で確認：
   - https://supabase.com にアクセス
   - Authentication → Users
   - 登録したユーザーが表示されていることを確認

### ステップ3: 既存アプリに統合

詳細な手順は **[AUTH_INTEGRATION_GUIDE.md](./AUTH_INTEGRATION_GUIDE.md)** を参照してください。

## 📁 実装済みの機能

### ✅ 認証デモ (auth_demo.html)

- ユーザー登録（メール+パスワード+名前）
- ログイン
- ログアウト
- ユーザー情報表示
- セッション管理

## 🔐 セキュリティについて

### APIキーの取り扱い

**重要:** ユーザーが自分のClaude APIキーを入力する方式を採用しています。

#### ✅ 安全な実装

```javascript
// セッション中のみメモリに保持
const [apiKey, setApiKey] = useState('');

// ログアウト時に自動的にクリア
```

#### ❌ 危険な実装（絶対NG）

```javascript
// localStorageに保存（危険！）
localStorage.setItem('claude_api_key', apiKey);
```

### ユーザーへの注意喚起

アプリに以下の警告を表示することを推奨します：

```
⚠️ APIキー管理のお願い
- APIキーは他人と共有しないでください
- 定期的にAPIキーを更新してください
- 不審なアクセスがあった場合はすぐにAPIキーを無効化してください
```

## 🗄️ データベース構造

### mangas テーブル

| 列名 | 型 | 説明 |
|------|------|------|
| id | UUID | 主キー（自動生成） |
| user_id | UUID | ユーザーID（auth.usersを参照） |
| image_url | TEXT | 漫画画像のURL |
| story | TEXT | 入力されたストーリー |
| style_id | INTEGER | スタイルID |
| style_name | TEXT | スタイル名 |
| settings | JSONB | その他の設定 |
| created_at | TIMESTAMP | 作成日時 |

### Row Level Security (RLS)

- ユーザーは自分のデータのみアクセス可能
- 他のユーザーのデータは読み取り・変更不可

## 📊 管理者ダッシュボード

Supabase Dashboardで以下を確認できます：

1. **Authentication → Users**
   - 登録ユーザー一覧
   - ユーザー名、メールアドレス
   - 登録日時、最終ログイン

2. **Table Editor → mangas**
   - 各ユーザーの投稿データ
   - 生成された漫画の一覧

3. **Storage → manga-images**
   - アップロードされた画像
   - ユーザーごとのフォルダ分け

## 🐛 トラブルシューティング

### エラー: "Invalid API key"

**原因:** SUPABASE_URLまたはSUPABASE_ANON_KEYが間違っている

**解決策:**
1. Supabase Dashboard → Settings → API で値を再確認
2. コピー時にスペースや改行が含まれていないか確認
3. auth_demo.htmlまたはindex.htmlの値を修正

### エラー: "User already registered"

**原因:** 同じメールアドレスで既に登録済み

**解決策:**
1. 別のメールアドレスを使用
2. または、既存のアカウントでログイン

### ログイン後、画面が真っ白

**原因:** JavaScriptエラーが発生している

**解決策:**
1. ブラウザのコンソールを開く（F12キー）
2. エラーメッセージを確認
3. Supabase設定値が正しいか再確認

### 画像が保存できない

**原因:** Storage設定またはポリシーの問題

**解決策:**
1. Supabase Dashboard → Storage → manga-images を確認
2. バケットが作成されているか確認
3. ポリシーが正しく設定されているか確認（SUPABASE_SETUP.mdの手順5を参照）

## 📞 サポート

### Supabase公式ドキュメント

- https://supabase.com/docs
- https://supabase.com/docs/guides/auth

### デバッグ方法

1. **ブラウザコンソール**
   - F12キーでデベロッパーツールを開く
   - Console タブでエラーを確認

2. **Supabase Logs**
   - Supabase Dashboard → Logs
   - エラーログを確認

## 🎯 次のステップ

認証機能の統合が完了したら：

1. ✅ 漫画生成機能のテスト
2. ✅ データ保存のテスト
3. ✅ 画像アップロードのテスト
4. ✅ Netlifyへのデプロイ
5. ✅ 本番環境でのテスト

---

**質問や問題がある場合:**
- SUPABASE_SETUP.md を再度確認
- AUTH_INTEGRATION_GUIDE.md で詳細な実装方法を確認
- Supabase Dashboardでエラーログを確認
