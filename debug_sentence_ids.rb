puts "=== 문장 ID 매칭 문제 분석 ==="

# 구동사 덱의 모든 문장 확인
phrasal_deck = Deck.find_by(name: "일상 필수 구동사 1000")
if phrasal_deck
  puts "구동사 덱 문장들:"
  phrasal_deck.sentences.order(:id).each do |sentence|
    puts "  ID: #{sentence.id}, 한국어: #{sentence.korean_text}"
    puts "  영어: #{sentence.english_text}"
    puts
  end
else
  puts "구동사 덱을 찾을 수 없습니다."
end

# 특정 문장 확인
target_sentence = Sentence.find_by(korean_text: "매일 아침 6시에 일어나요.")
if target_sentence
  puts "=== 타겟 문장 확인 ==="
  puts "ID: #{target_sentence.id}"
  puts "한국어: #{target_sentence.korean_text}"
  puts "영어: #{target_sentence.english_text}"
  puts "덱: #{target_sentence.deck.name}"
else
  puts "타겟 문장을 찾을 수 없습니다."
end

# 불 켜는 문장 확인
light_sentence = Sentence.find_by(korean_text: "불을 켜주세요, 너무 어두워요.")
if light_sentence
  puts "=== 불 켜는 문장 확인 ==="
  puts "ID: #{light_sentence.id}"
  puts "한국어: #{light_sentence.korean_text}"
  puts "영어: #{light_sentence.english_text}"
  puts "덱: #{light_sentence.deck.name}"
else
  puts "불 켜는 문장을 찾을 수 없습니다."
end