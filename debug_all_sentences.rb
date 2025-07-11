puts "=== 전체 문장 ID 매핑 확인 ==="
Sentence.all.order(:id).each do |sentence|
  puts "ID #{sentence.id} (#{sentence.deck.name}): #{sentence.korean_text} -> #{sentence.english_text}"
end
puts

puts "=== 각 덱별 문장 확인 ==="
Deck.all.each do |deck|
  puts "#{deck.name} 덱:"
  deck.sentences.order(:id).each do |sentence|
    puts "  ID #{sentence.id}: #{sentence.korean_text}"
  end
  puts
end

puts "=== 문제 발생 시나리오 테스트 ==="
# 각 덱의 첫 번째 문장들로 테스트
[1, 4, 14, 24, 35].each do |sentence_id|
  sentence = Sentence.find_by(id: sentence_id)
  if sentence
    puts "문장 ID #{sentence_id}: #{sentence.korean_text}"
    puts "  실제 영어: #{sentence.english_text}"
    puts "  덱: #{sentence.deck.name}"
  else
    puts "문장 ID #{sentence_id}: 존재하지 않음"
  end
  puts
end