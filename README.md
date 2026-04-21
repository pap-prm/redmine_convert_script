# Redmine Textile → Markdown Converter

A set of scripts for migrating text formatting from legacy **Textile** syntax to modern **Markdown** in a Redmine database. The scripts process descriptions of issues, wiki pages, comments, news, forum messages, and project descriptions.

## 📦 Contents

| File | Purpose |
|------|---------|
| `1_convert_lists.rb` | Convert numbered lists: `#`, `##`, `###` → `1. `, `   2. `, `       3. ` |
| `2_convert_headers.rb` | Convert headings: `h1.`, `h2.` → `#`, `##` |
| `3_convert_images.rb` | Convert image embeds: `!url!` → `![ ](url)` |
| `4_convert_tables.rb` | Convert Textile tables with `|_.` separator to Markdown tables |
| `5_convert_code_blocks.rb` | Convert code blocks: `<pre><code class="ruby">...</code></pre>` → ````ruby ... ```` |
| `6_convert_inline_code.rb` | Convert inline code: `@code@` → `` `code` `` |
| `7_convert_call_user.rb` | Fix broken user mentions: `` `username` `` → `@username` |
| `8_convert_pre.rb` | Universal handling of `<pre>` tags (including those without nested `<code>`) |
| `9_convert_url.rb` | Convert Textile links: `"text":url` → `[text](url)` |
| `export_failed.rb` | Export records that could not be converted (for manual inspection) |
| `find_textile.rb` | Search for remaining Textile constructs after all migrations |

## 🚀 Execution Order

The recommended order for running the scripts (each should be executed separately in the Rails console):

```bash
bundle exec rails runner 1_convert_lists.rb
bundle exec rails runner 2_convert_headers.rb
bundle exec rails runner 3_convert_images.rb
bundle exec rails runner 4_convert_tables.rb
bundle exec rails runner 5_convert_code_blocks.rb
bundle exec rails runner 6_convert_inline_code.rb
bundle exec rails runner 7_convert_call_user.rb
bundle exec rails runner 8_convert_pre.rb
bundle exec rails runner 9_convert_url.rb
```

After completing the main conversions, it is useful to run:

```bash
bundle exec rails runner find_textile.rb    # search for remaining constructs
bundle exec rails runner export_failed.rb   # export problematic records to /tmp/failed_records.txt
```

## ⚠️ Important Warnings

1. **Make a full database backup before running!** The scripts modify data irreversibly.
2. **Test on a copy of the production database.** Run the scripts in a test environment first and verify the results.
3. **Follow the specified order.** Some conversions depend on others (e.g., headers before lists; code is processed in multiple passes).
4. **Execution time.** Depending on the database size, execution may take from several minutes to hours.
5. **Models.** Each script defines an array of models to process. You can uncomment or comment out lines for models that should be skipped.
6. **Encoding.** The scripts assume UTF-8 text.

## 📋 Requirements

- Redmine (tested on versions 3.x–5.x)
- Ruby (the version used by your Redmine installation)
- Access to the Rails console (`rails console` or `rails runner`)

## 🔍 Understanding the Output

Each script outputs statistics for each model:

```
Issue: Found=123, Updated=120, Remaining=3
WikiContent: Found=45, Updated=45, Remaining=0
...
```

- **Found** — number of records containing the target pattern.
- **Updated** — number of records successfully modified.
- **Remaining** / **Errors** — records that could not be converted (original patterns still present or database errors occurred).

If any script shows a non-zero value in the "Remaining" column, it is recommended to analyze those records using `export_failed.rb` and fix them manually.

## 📝 License

MIT — use at your own risk. The author is not responsible for any data loss.
