puts "Fixing broken mentions `User -> @User..."

models = [
  { model: Issue, field: :description },
  { model: WikiContent, field: :text },
  { model: Journal, field: :notes },
  { model: News, field: :description },
  { model: Message, field: :content },
  { model: Project, field: :description },
]

# (?<!\`) — пропускаем, если перед бэктиком уже есть бэктик (часть `` или ```)
# (?!\`)  — пропускаем, если после слова сразу идёт бэктик (закрывающий inline-код)
broken_pattern = /(?<!\`)\`([A-Za-zА-Яа-яЁё0-9._-]+)(?!\`)/

models.each do |item|
  total = 0
  updated = 0
  failed = 0

  item[:model].find_each(batch_size: 200) do |record|
    text = record.send(item[:field])
    next unless text

    if text.match?(broken_pattern)
      total += 1
      new_text = text.gsub(broken_pattern, '@\1')
      begin
        record.update_columns(item[:field] => new_text)
        updated += 1
      rescue => e
        failed += 1
        puts "  Ошибка #{item[:model].name}##{record.id}: #{e.message}"
      end
    end
  end

  puts "#{item[:model].name}: Найдено=#{total}, Обновлено=#{updated}, Ошибки=#{failed}"
end
puts "Finish!"
