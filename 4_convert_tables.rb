puts "Convert tables Textile -> Markdown..."

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

def count_columns(line)
  cells = line.strip.gsub(/^\|/, '').gsub(/\|$/, '').split('|')
  cells.length
end

def make_separator(cols)
  '|' + ('---|' * cols)
end

models.each do |item|
  total = 0
  updated = 0
  failed = 0
  item[:model].find_each do |record|
    text = record.send(item[:field])
    next unless text
    if text.match?(/\|_\./)
      total += 1
      lines = text.split("\n")
      new_lines = []
      i = 0
      while i < lines.length
        line = lines[i]
        if line.match?(/^\|.*\|_\./) || line.match?(/^\|_\./)
          header = line.gsub(/\|_\./, '|')
          new_lines << header
          cols = count_columns(header)
          new_lines << make_separator(cols)
          i += 1
          while i < lines.length && lines[i].strip.start_with?('|') && !lines[i].match?(/\|_\./)
            new_lines << lines[i]
            i += 1
          end
        else
          new_lines << line
          i += 1
        end
      end
      new_text = new_lines.join("\n")
      if new_text.match?(/\|_\./)
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
