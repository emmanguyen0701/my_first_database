require_relative 'questionsDatabase'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'

class User
    attr_accessor :fname, :lname, :id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM users")
        data.map { |datum| User.new(datum) }
    end

    def self.find_by_id(id)
        users = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM 
                users
            WHERE
                id = ?
        SQL
        return nil if users.length < 1
        User.new(users.first)
    end

    def self.find_by_name(fname, lname)
        users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT 
                *
            FROM
                users
            WHERE
                lname = ? AND fname = ? 
        SQL
        return nil if users.length < 1
        Users.new(users.first)
    end

    def initialize(options)
        @id = options['id']
        @lname = options['lname']
        @fname = options['fname']
    end
    
    def save
        if @id
            QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id )
                UPDATE
                    users
                SET
                    lname = ?, fname = ?
                WHERE
                    id = ?
            SQL
        else
            QuestionsDatabase.instance.execute(<<-SQL, @lname, @fname)
                INSERT INTO
                    users(lname, fname)
                VALUES
                    (?, ?)
            SQL
            @id = QuestionsDatabase.instance.last_insert_row_id
        end
        self
    end

    def authored_questions      
        Question.find_by_author_id(id)
    end

    def authored_replies
        Reply.find_by_user_id(id)
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(id)
    end

end