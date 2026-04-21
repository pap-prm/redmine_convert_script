puts "Поиск записей с Textile..."
models = [
  { model: Issue, field: :description },
  { model: WikiContent, field: :text },
  { model: Journal, field: :notes }
]
patterns = [
  { name: "Заголовки", regex: /^h[1-6]\.\s+/ },
  { name: "Списки", regex: /^\s*#+\s+/ },
  { name: "Картинки", regex: /!([^!]+)!/ },
  { name: "Таблицы", regex: /\|_\./ },
  { name: "Код inline", regex: /@([^@]+)@/ }
]
models.each do |item|
  patterns.each do |pat|
    count = 0
    item[:model].find_each do |record|
      text = record.send(item[:field])
      next unless text
      if text.match?(pat[:regex])
        puts "#{item[:model].name} ##{record.id} [#{pat[:name]}]: #{text[0..100]}..."
        count += 1
        break if count >= 10
      end
    end
    puts "Найдено #{item[:model].name} с паттерном '#{pat[:name]}': #{count} (показано до 10)"
  end
end
puts "Finish!"
