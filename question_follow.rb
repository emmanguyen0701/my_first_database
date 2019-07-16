require_relative 'questionsDatabase'
require_relative 'question'
require_relative 'user'
require_relative 'reply'
require_relative 'question_like'

class QuestionFollow
    attr_reader :id
    attr_accessor :user_id, :question_id

    def self.find_by_id(id)
        questionFollows = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_follows
            WHERE
                id = ?
        SQL
        return nil if questionFollows.length < 1
        QuestionFollow.new(questionFollows.first)
    end

    def self.followers_for_question_id(question_id)
        followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT 
                users.* 
            FROM
                question_follows
            JOIN               
                users ON question_follows.user_id = users.id
            WHERE
                question_id = ?
        SQL
        return nil if followers.length < 1
        followers
    end

    def self.followed_questions_for_user_id(user_id)
        followed_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                questions.*
            FROM
                question_follows
            JOIN
                questions ON question_follows.question_id = questions.id
            WHERE
                user_id = ?
        SQL
        return nil if followed_questions.length < 1
        followed_questions
    end

    def self.most_followed_questions(n)
        most_followed = QuestionsDatabase.instance.execute(<<-SQL, limit: n)
            SELECT
                questions.*
            FROM
                question_follows
            JOIN
                questions ON question_follows.question_id = questions.id
            GROUP BY
                question_follows.user_id
            ORDER BY
                COUNT(user_id) DESC
            LIMIT
                :limit
        SQL
        most_followed.map{ |followed| Question.new(followed) }
    end

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

end