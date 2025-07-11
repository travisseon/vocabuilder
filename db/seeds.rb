# VocaBuilder Seeds

# Create Daily Quotes
daily_quotes = [
  {
    english_text: "Time is what we want most, but what we use worst.",
    korean_text: "시간은 우리가 가장 원하는 것이지만, 가장 잘못 사용하는 것이다.",
    author: "William Penn",
    is_active: true,
    display_date: Date.current
  },
  {
    english_text: "The only way to do great work is to love what you do.",
    korean_text: "위대한 일을 하는 유일한 방법은 당신이 하는 일을 사랑하는 것이다.",
    author: "Steve Jobs",
    is_active: true,
    display_date: Date.current + 1.day
  },
  {
    english_text: "Life is what happens to you while you're busy making other plans.",
    korean_text: "인생은 당신이 다른 계획을 세우느라 바쁠 때 당신에게 일어나는 것이다.",
    author: "John Lennon",
    is_active: true,
    display_date: Date.current + 2.days
  }
]

daily_quotes.each do |quote|
  DailyQuote.find_or_create_by(english_text: quote[:english_text]) do |dq|
    dq.korean_text = quote[:korean_text]
    dq.author = quote[:author]
    dq.is_active = quote[:is_active]
    dq.display_date = quote[:display_date]
  end
end

# Create Decks
decks = [
  {
    name: "일상영어회화",
    description: "일상생활에서 자주 사용하는 영어 표현들을 배워보세요.",
    difficulty_level: 1
  },
  {
    name: "토익공부",
    description: "토익 시험에 자주 출제되는 문장들을 연습해보세요.",
    difficulty_level: 2
  },
  {
    name: "비즈니스 영어",
    description: "직장에서 사용하는 전문적인 영어 표현들을 학습하세요.",
    difficulty_level: 3
  }
]

decks.each do |deck_data|
  deck = Deck.find_or_create_by(name: deck_data[:name]) do |d|
    d.description = deck_data[:description]
    d.difficulty_level = deck_data[:difficulty_level]
  end
end

# Create Sentences and Words
daily_conversation = Deck.find_by(name: "일상영어회화")

sentences_data = [
  {
    korean_text: "마감까지 얼마나 많은 시간이 있나요?",
    english_text: "How much time do we have until the deadline?",
    words: ["How", "much", "time", "do", "we", "have", "until", "the", "deadline", "?"],
    distractors: ["many", "when", "where", "why"]
  },
  {
    korean_text: "오늘 날씨가 정말 좋네요.",
    english_text: "The weather is really nice today.",
    words: ["The", "weather", "is", "really", "nice", "today", "."],
    distractors: ["very", "good", "beautiful", "sunny"]
  },
  {
    korean_text: "이 문제를 어떻게 해결할 수 있을까요?",
    english_text: "How can we solve this problem?",
    words: ["How", "can", "we", "solve", "this", "problem", "?"],
    distractors: ["fix", "handle", "deal", "manage"]
  }
]

sentences_data.each do |sentence_data|
  sentence = Sentence.find_or_create_by(
    deck: daily_conversation,
    korean_text: sentence_data[:korean_text]
  ) do |s|
    s.english_text = sentence_data[:english_text]
    s.word_count = sentence_data[:words].length
    s.difficulty_level = 1
  end
  
  # Create correct words
  sentence_data[:words].each_with_index do |word, index|
    Word.find_or_create_by(
      sentence: sentence,
      word: word,
      position: index + 1
    ) do |w|
      w.is_distractor = false
    end
  end
  
  # Create distractor words
  sentence_data[:distractors].each do |distractor|
    Word.find_or_create_by(
      sentence: sentence,
      word: distractor,
      position: 0
    ) do |w|
      w.is_distractor = true
    end
  end
end

# Create Verb Explanations
sentence1 = Sentence.find_by(korean_text: "마감까지 얼마나 많은 시간이 있나요?")
if sentence1
  VerbExplanation.find_or_create_by(
    sentence: sentence1,
    verb: "have"
  ) do |ve|
    ve.explanation = "여기서 'have'는 '소유하다'가 아닌 '시간이 있다/남아있다'라는 의미로 사용됩니다. 시간의 존재나 가용성을 나타내는 표현입니다."
    ve.comparison = "'get'을 사용하면 시간을 '얻다'는 의미가 되고, 'take'를 사용하면 시간이 '걸리다'는 의미가 됩니다."
    ve.examples = "We have 30 minutes before the meeting. (회의 전까지 30분이 있다) | Do you have time to help me? (저를 도와줄 시간이 있나요?)"
  end
end

# Update deck sentence counts
Deck.all.each do |deck|
  deck.update(total_sentences: deck.sentences.count)
end

puts "Seeds created successfully!"
puts "- #{DailyQuote.count} daily quotes"
puts "- #{Deck.count} decks"
puts "- #{Sentence.count} sentences"
puts "- #{Word.count} words"
puts "- #{VerbExplanation.count} verb explanations"
