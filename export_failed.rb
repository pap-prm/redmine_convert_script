puts "Export failed records..."

models = [
  { model: Issue, field: :description },
  { model: WikiContent, field: :text },
  { model: Journal, field: :notes }
]

patterns = {
  "images" => /!([^!]+)!/,
  "tables" => /\|_\./,
  "code_blocks" => /<pre>\s*<code\s+class="(\w+)">\s*(.*?)\s*<\/code>\s*<\/pre>/m,
  "inline_code" => /@([^@]+)@/
}

File.open("/tmp/failed_records.txt", "w") do |f|
  models.each do |item|
    patterns.each do |name, pattern|
      item[:model].find_each do |record|
        text = record.send(item[:field])
        next unless text && text.match?(pattern)
        f.puts "=== #{item[:model].name} ##{record.id} [#{name}] ==="
        f.puts text[0..1000]
        f.puts "\n" + ("-" * 80) + "\n"
      end
    end
  end
end
puts "Finish! Source: /tmp/failed_records.txt"
