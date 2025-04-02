import Foundation

struct Quote {
    let text: String
    let author: String
}

class QuoteManager {
    // Singleton instance
    static let shared = QuoteManager()
    
    // Collection of motivational quotes
    private let quotes: [Quote] = [
        // Success and Achievement
        Quote(text: "The future depends on what you do today.", author: "Mahatma Gandhi"),
        Quote(text: "It always seems impossible until it's done.", author: "Nelson Mandela"),
        Quote(text: "Success is not final, failure is not fatal: It is the courage to continue that counts.", author: "Winston Churchill"),
        Quote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
        Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
        Quote(text: "If you're going through hell, keep going.", author: "Winston Churchill"),
        Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        Quote(text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky"),
        Quote(text: "I have not failed. I've just found 10,000 ways that won't work.", author: "Thomas Edison"),
        Quote(text: "The only place where success comes before work is in the dictionary.", author: "Vidal Sassoon"),
        
        // Productivity and Focus
        Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
        Quote(text: "Focus on being productive instead of busy.", author: "Tim Ferriss"),
        Quote(text: "You don't have to be great to start, but you have to start to be great.", author: "Zig Ziglar"),
        Quote(text: "Productivity is never an accident. It is always the result of a commitment to excellence.", author: "Paul J. Meyer"),
        Quote(text: "The most effective way to do it, is to do it.", author: "Amelia Earhart"),
        Quote(text: "Your mind is for having ideas, not holding them.", author: "David Allen"),
        Quote(text: "Action is the foundational key to all success.", author: "Pablo Picasso"),
        Quote(text: "Time is what we want most, but what we use worst.", author: "William Penn"),
        Quote(text: "Until we can manage time, we can manage nothing else.", author: "Peter Drucker"),
        Quote(text: "The key is not to prioritize what's on your schedule, but to schedule your priorities.", author: "Stephen Covey"),
        
        // Education and Learning
        Quote(text: "Education is not the learning of facts, but the training of the mind to think.", author: "Albert Einstein"),
        Quote(text: "Live as if you were to die tomorrow. Learn as if you were to live forever.", author: "Mahatma Gandhi"),
        Quote(text: "The beautiful thing about learning is that nobody can take it away from you.", author: "B.B. King"),
        Quote(text: "The more that you read, the more things you will know. The more that you learn, the more places you'll go.", author: "Dr. Seuss"),
        Quote(text: "Education is the passport to the future, for tomorrow belongs to those who prepare for it today.", author: "Malcolm X"),
        Quote(text: "The capacity to learn is a gift; the ability to learn is a skill; the willingness to learn is a choice.", author: "Brian Herbert"),
        Quote(text: "Anyone who stops learning is old, whether at twenty or eighty.", author: "Henry Ford"),
        Quote(text: "Tell me and I forget. Teach me and I remember. Involve me and I learn.", author: "Benjamin Franklin"),
        Quote(text: "Learning is not attained by chance, it must be sought for with ardor and diligence.", author: "Abigail Adams"),
        Quote(text: "An investment in knowledge pays the best interest.", author: "Benjamin Franklin"),
        
        // Perseverance and Resilience
        Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
        Quote(text: "Fall seven times, stand up eight.", author: "Japanese Proverb"),
        Quote(text: "The only limit to our realization of tomorrow will be our doubts of today.", author: "Franklin D. Roosevelt"),
        Quote(text: "When you come to the end of your rope, tie a knot and hang on.", author: "Franklin D. Roosevelt"),
        Quote(text: "Character consists of what you do on the third and fourth tries.", author: "James A. Michener"),
        Quote(text: "Courage doesn't always roar. Sometimes courage is the quiet voice at the end of the day saying, 'I will try again tomorrow.'", author: "Mary Anne Radmacher"),
        Quote(text: "The gem cannot be polished without friction, nor man perfected without trials.", author: "Chinese Proverb"),
        Quote(text: "The difference between a successful person and others is not a lack of strength, not a lack of knowledge, but rather a lack of will.", author: "Vince Lombardi"),
        Quote(text: "Perseverance is not a long race; it is many short races one after the other.", author: "Walter Elliot"),
        Quote(text: "Life isn't about waiting for the storm to pass, it's about learning to dance in the rain.", author: "Vivian Greene"),
        
        // Time Management
        Quote(text: "The bad news is time flies. The good news is you're the pilot.", author: "Michael Altshuler"),
        Quote(text: "Yesterday is gone. Tomorrow has not yet come. We have only today. Let us begin.", author: "Mother Teresa"),
        Quote(text: "Don't say you don't have enough time. You have exactly the same number of hours per day that were given to Helen Keller, Pasteur, Michelangelo, da Vinci, and Einstein.", author: "H. Jackson Brown Jr."),
        Quote(text: "The two most powerful warriors are patience and time.", author: "Leo Tolstoy"),
        Quote(text: "Time is the school in which we learn, time is the fire in which we burn.", author: "Delmore Schwartz"),
        Quote(text: "Either you run the day or the day runs you.", author: "Jim Rohn"),
        Quote(text: "The trouble is, you think you have time.", author: "Buddha"),
        Quote(text: "Time you enjoy wasting is not wasted time.", author: "Marthe Troly-Curtin"),
        Quote(text: "A man who dares to waste one hour of time has not discovered the value of life.", author: "Charles Darwin"),
        Quote(text: "Lost time is never found again.", author: "Benjamin Franklin"),
        
        // Personal Growth
        Quote(text: "Life is 10% what happens to you and 90% how you react to it.", author: "Charles R. Swindoll"),
        Quote(text: "Be not afraid of growing slowly; be afraid only of standing still.", author: "Chinese Proverb"),
        Quote(text: "Change is the end result of all true learning.", author: "Leo Buscaglia"),
        Quote(text: "The only person you are destined to become is the person you decide to be.", author: "Ralph Waldo Emerson"),
        Quote(text: "Growth is the only evidence of life.", author: "John Henry Newman"),
        Quote(text: "We cannot become what we want by remaining what we are.", author: "Max Depree"),
        Quote(text: "If you don't like something, change it. If you can't change it, change your attitude.", author: "Maya Angelou"),
        Quote(text: "What you do today can improve all your tomorrows.", author: "Ralph Marston"),
        Quote(text: "The unexamined life is not worth living.", author: "Socrates"),
        Quote(text: "Every strike brings me closer to the next home run.", author: "Babe Ruth"),
        
        // Planning and Goals
        Quote(text: "A goal without a plan is just a wish.", author: "Antoine de Saint-Exupéry"),
        Quote(text: "By failing to prepare, you are preparing to fail.", author: "Benjamin Franklin"),
        Quote(text: "Setting goals is the first step in turning the invisible into the visible.", author: "Tony Robbins"),
        Quote(text: "Our goals can only be reached through a vehicle of a plan, in which we must fervently believe, and upon which we must vigorously act.", author: "Pablo Picasso"),
        Quote(text: "If you have a dream, don't just sit there. Gather courage to believe that you can succeed and leave no stone unturned to make it a reality.", author: "Dr. Roopleen"),
        Quote(text: "Goals are dreams with deadlines.", author: "Diana Scharf"),
        Quote(text: "If you want to live a happy life, tie it to a goal, not to people or things.", author: "Albert Einstein"),
        Quote(text: "The greater danger for most of us isn't that our aim is too high and miss it, but that it is too low and we reach it.", author: "Michelangelo"),
        Quote(text: "Obstacles are those frightful things you see when you take your eyes off your goal.", author: "Henry Ford"),
        Quote(text: "What you get by achieving your goals is not as important as what you become by achieving your goals.", author: "Zig Ziglar"),
        
        // Innovation and Creativity
        Quote(text: "Imagination is more important than knowledge.", author: "Albert Einstein"),
        Quote(text: "Creativity is intelligence having fun.", author: "Albert Einstein"),
        Quote(text: "The best way to predict the future is to create it.", author: "Peter Drucker"),
        Quote(text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs"),
        Quote(text: "You can't use up creativity. The more you use, the more you have.", author: "Maya Angelou"),
        Quote(text: "The true sign of intelligence is not knowledge but imagination.", author: "Albert Einstein"),
        Quote(text: "Creativity involves breaking out of established patterns in order to look at things in a different way.", author: "Edward de Bono"),
        Quote(text: "Every artist was first an amateur.", author: "Ralph Waldo Emerson"),
        Quote(text: "The greatest discovery of all time is that a person can change their future by merely changing their attitude.", author: "Oprah Winfrey"),
        Quote(text: "The difficulty lies not so much in developing new ideas as in escaping from old ones.", author: "John Maynard Keynes"),
        
        // Inspiration for Students
        Quote(text: "The expert in anything was once a beginner.", author: "Helen Hayes"),
        Quote(text: "The mind is not a vessel to be filled, but a fire to be kindled.", author: "Plutarch"),
        Quote(text: "The roots of education are bitter, but the fruit is sweet.", author: "Aristotle"),
        Quote(text: "The best preparation for tomorrow is doing your best today.", author: "H. Jackson Brown, Jr."),
        Quote(text: "The harder you work for something, the greater you'll feel when you achieve it.", author: "Anonymous"),
        Quote(text: "Your attitude, not your aptitude, will determine your altitude.", author: "Zig Ziglar"),
        Quote(text: "Motivation is what gets you started. Habit is what keeps you going.", author: "Jim Rohn"),
        Quote(text: "The difference between ordinary and extraordinary is that little extra.", author: "Jimmy Johnson"),
        Quote(text: "The more you know, the more you realize you don't know.", author: "Aristotle"),
        Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
        
        // Additional General Motivation
        Quote(text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis"),
        Quote(text: "Whether you think you can or you think you can't, you're right.", author: "Henry Ford"),
        Quote(text: "Everything you've ever wanted is on the other side of fear.", author: "George Addair"),
        Quote(text: "Your time is limited, don't waste it living someone else's life.", author: "Steve Jobs"),
        Quote(text: "Twenty years from now you will be more disappointed by the things that you didn't do than by the ones you did do.", author: "Mark Twain"),
        Quote(text: "Do what you can, with what you have, where you are.", author: "Theodore Roosevelt"),
        Quote(text: "Act as if what you do makes a difference. It does.", author: "William James"),
        Quote(text: "Strive not to be a success, but rather to be of value.", author: "Albert Einstein"),
        Quote(text: "The most common way people give up their power is by thinking they don't have any.", author: "Alice Walker"),
        Quote(text: "Start where you are. Use what you have. Do what you can.", author: "Arthur Ashe")
    ]
    
    // Get a random quote
    func getRandomQuote() -> Quote {
        let randomIndex = Int.random(in: 0..<quotes.count)
        return quotes[randomIndex]
    }
    
    // Get a quote by category (could be expanded later)
    func getQuoteByCategory(_ category: QuoteCategory) -> Quote {
        var filteredQuotes: [Quote] = []
        
        switch category {
        case .success:
            filteredQuotes = quotes.prefix(10).map { $0 }
        case .productivity:
            filteredQuotes = Array(quotes.dropFirst(10).prefix(10))
        case .education:
            filteredQuotes = Array(quotes.dropFirst(20).prefix(10))
        case .perseverance:
            filteredQuotes = Array(quotes.dropFirst(30).prefix(10))
        case .timeManagement:
            filteredQuotes = Array(quotes.dropFirst(40).prefix(10))
        case .personalGrowth:
            filteredQuotes = Array(quotes.dropFirst(50).prefix(10))
        case .planning:
            filteredQuotes = Array(quotes.dropFirst(60).prefix(10))
        case .innovation:
            filteredQuotes = Array(quotes.dropFirst(70).prefix(10))
        case .student:
            filteredQuotes = Array(quotes.dropFirst(80).prefix(10))
        case .general:
            filteredQuotes = Array(quotes.dropFirst(90).prefix(10))
        }
        
        let randomIndex = Int.random(in: 0..<filteredQuotes.count)
        return filteredQuotes[randomIndex]
    }
    
    // Get daily quote - could be enhanced to provide a consistent quote for a day
    func getDailyQuote() -> Quote {
        // Create a date formatter for just year-month-day to create a consistent seed
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        // Get today's date as string
        let todayString = dateFormatter.string(from: Date())
        
        // Create a deterministic seed based on the date
        var seed = 0
        for char in todayString {
            if let digit = Int(String(char)) {
                seed += digit
            }
        }
        
        // Use the seed to get a consistent quote for the day
        let index = seed % quotes.count
        return quotes[index]
    }
}

// Quote Categories for potential future use
enum QuoteCategory {
    case success
    case productivity
    case education
    case perseverance
    case timeManagement
    case personalGrowth
    case planning
    case innovation
    case student
    case general
}
