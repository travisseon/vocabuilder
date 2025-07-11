puts "=== 문장 18번 확인 ==="
sentence_18 = Sentence.find(18)
puts "ID #{sentence_18.id}: #{sentence_18.korean_text} -> #{sentence_18.english_text}"
puts "덱: #{sentence_18.deck.name}"
puts

puts "=== 실망시켜서 죄송해요 문장 찾기 ==="
sorry_sentence = Sentence.find_by(korean_text: "실망시켜서 죄송해요.")
if sorry_sentence
  puts "실망시켜서 죄송해요 - ID #{sorry_sentence.id}: #{sorry_sentence.korean_text} -> #{sorry_sentence.english_text}"
  puts "덱: #{sorry_sentence.deck.name}"
else
  puts "실망시켜서 죄송해요 문장을 찾을 수 없음"
end
puts

puts "=== I put away my clothes 문장 찾기 ==="
clothes_sentence = Sentence.find_by(english_text: "I put away my clothes.")
if clothes_sentence
  puts "I put away my clothes - ID #{clothes_sentence.id}: #{clothes_sentence.korean_text} -> #{clothes_sentence.english_text}"
  puts "덱: #{clothes_sentence.deck.name}"
else
  puts "I put away my clothes 문장을 찾을 수 없음"
end
puts

puts "=== 실제 URL과 문장 매핑 확인 ==="
puts "사용자가 학습 중인 덱과 문장 확인"
user = User.find(1)
puts "사용자: #{user.nickname}"
puts

# 각 덱별로 현재 학습 중인 문장 확인
Deck.all.each do |deck|
  puts "#{deck.name} 덱 (ID: #{deck.id}):"
  completed_ids = user.learning_records.joins(:sentence).where(sentences: { deck: deck }).where(status: ["learning", "learned", "mastered"]).pluck(:sentence_id)
  next_sentence = deck.sentences.where.not(id: completed_ids).order(:id).first
  if next_sentence
    puts "  다음 학습 문장: ID #{next_sentence.id} - #{next_sentence.korean_text}"
    puts "  URL: /decks/#{deck.id}/sentences/#{next_sentence.id}"
  else
    puts "  완료된 덱"
  end
  puts
end

puts "=== DB 구조 확인 ==="
puts "Sentence 테이블 스키마:"
puts "- id: 고유 ID (전체 시스템)"
puts "- deck_id: 덱 ID (외래키)"
puts "- korean_text: 한국어 문장"
puts "- english_text: 영어 문장"
puts
puts "현재 각 덱의 sentence_id 범위:"
Deck.all.each do |deck|
  sentence_ids = deck.sentences.pluck(:id)
  if sentence_ids.any?
    puts "#{deck.name}: #{sentence_ids.min}-#{sentence_ids.max} (총 #{sentence_ids.count}개)"
  else
    puts "#{deck.name}: 문장 없음"
  end
end
puts

puts "=== 라우팅 확인 ==="
puts "현재 라우팅: /decks/:deck_id/sentences/:sentence_id"
puts "- deck_id: 덱의 고유 ID"
puts "- sentence_id: 문장의 전체 시스템 고유 ID"
puts
puts "문제점 분석:"
puts "1. sentence_id가 전체 시스템의 고유 ID를 사용"
puts "2. 각 덱 내에서의 순서와 전체 시스템 ID가 다름"
puts "3. URL의 deck_id와 sentence_id 매핑에 오류 가능성"