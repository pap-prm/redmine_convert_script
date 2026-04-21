puts "Convert URLs Textile \"text\":url -> [text](url)..."

models = [
  { model: Issue, field: :description },
  { model: WikiContent, field: :text },
  { model: Journal, field: :notes },
  { model: News, field: :description },
  { model: Message, field: :content },
  { model: Project, field: :description },
]

pattern = /"([^"]+)":(https?:\/\/[^\s\)'"\],;:!?|]+)/

models.each do |item|
  total = 0
  updated = 0
  failed = 0

  item[:model].find_each(batch_size: 200) do |record|
    text = record.send(item[:field])
    next unless text

    if text.match?(pattern)
      new_text = text.gsub(pattern, '[\1](\2)')
      if new_text != text
        total += 1
        begin
          record.update_columns(item[:field] => new_text)
          updated += 1
        rescue => e
          failed += 1
          puts "  Ошибка #{item[:model].name}##{record.id}: #{e.message}"
        end
      end
    end
  end

  puts "#{item[:model].name}: Found=#{total}, Updated=#{updated}, Remaining=#{failed}"
end
puts "Finish!"
