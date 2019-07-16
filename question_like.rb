require_relative 'questionsDatabase'
require_relative 'user'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'


class QuestionLike
    attr_reader :id
    attr_accessor :user_id, :quesiton_id

    def self.find_by_id(id)
        questionLike = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_likes
            WHERE 
                id = ?
        SQL
        return nil if questionLike.length < 1
        QuestionLike.new(questionLike.first)
    end

    def self.likers_for_question_id(question_id)
        likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                users.*
            FROM
                question_likes
            JOIN
                users ON question_likes.user_id = users.id
            WHERE
                question_id = ?
        SQL
        return nil if likers.length < 1
        likers.map{ |liker_datum| User.new(liker_datum) }
    end

    def self.num_likes_for_question_id(question_id)
        QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
            SELECT
                COUNT(*) AS likes
            FROM
                questions
            JOIN
                question_likes ON questions.id = question_likes.question_id 
            WHERE
                questions.id = :question_id
        SQL
    end

    def self.liked_questions_for_user_id(user_id)
        liked_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
            SELECT
                questions.*
            FROM 
                questions
            JOIN
                question_likes ON questions.id = question_likes.question_id
            JOIN
                users ON question_likes.user_id = users.id
            WHERE
                users.id = :user_id
        SQL
        return nil if liked_questions.length < 1
        liked_questions.map{ |liked_datum| Question.new(liked_datum) }
    end

    def self.most_liked_questions(n)
        most_liked = QuestionsDatabase.instance.execute(<<-SQL, limit: n)
            SELECT
                questions.*
            FROM
                questions
            JOIN
                question_likes ON questions.id = question_likes.question_id
            GROUP BY
                question_likes.user_id
            ORDER BY
                COUNT(question_likes.user_id) DESC
            LIMIT
                :limit
        SQL
        most_liked.map{ |like_datum| Question.new(like_datum) }
    end
    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @quesiton_id = options['question_id']
    end
end