puts "Convert lists # -> 1...."

models = [
  { model: Issue, field: :description },
  { model: WikiContent, field: :text },
  { model: Journal, field: :notes },
  { model: News, field: :description },
#  { model: Document, field: :description },
  { model: Message, field: :content }, 
#  { model: Changeset, field: :comments },
  { model: Project, field: :description },
#  { model: Attachment, field: :description }
]

pattern = /^\s*(#+)\s+/

models.each do |item|
  total = 0
  updated = 0
  failed = 0
  item[:model].find_each do |record|
    text = record.send(item[:field])
    next unless text
    if text.match?(pattern)
      total += 1
      new_text = text.gsub(pattern) { "    " * ($1.length - 1) + "1. " }
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
