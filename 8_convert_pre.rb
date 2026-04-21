puts "Code block conversion <pre> -> ```..."

models = [
  { model: Issue, field: :description },
  { model: WikiContent, field: :text },
  { model: Journal, field: :notes },
  { model: News, field: :description },
  { model: Message, field: :content },
  { model: Project, field: :description },
]

pattern = /(?i)<pre>\s*(?:<code(?:\s+class="(\w+)")?>\s*)?(.*?)\s*(?:<\/code>)?\s*<\/pre>/m

models.each do |item|
  total = 0
  updated = 0
  failed = 0
  item[:model].find_each(batch_size: 200) do |record|
    text = record.send(item[:field])
    next unless text
    if text.match?(pattern)
      total += 1
      new_text = text.gsub(pattern) do
        lang = $1 || ''
        content = $2.strip
        "```#{lang}\n#{content}\n```"
      end
      if new_text.match?(pattern)
        failed += 1
      else
        updated += 1
        record.update_columns(item[:field] => new_text)
      end
    end
  end
  puts "#{item[:model].name}: Found=#{total}, Updated=#{updated}, Remaining=#{failed}"
end
puts "Finish!"
