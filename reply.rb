require_relative 'questionsDatabase'
require_relative 'question'
require_relative 'user'
require_relative 'question_follow'
require_relative 'question_like'

class Reply
    
    attr_accessor :id, :question_id, :parent_reply_key, :author_id, :body

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_id(id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT 
                *
            FROM
                replies
            WHERE
                id = ?
        SQL
        return nil if replies.length < 1
        Reply.new(replies.first)
    end

    def self.find_by_parent_id(parent_reply_key)
        parent_replies = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id: parent_reply_key)
            SELECT 
                replies.*
            FROM
                replies
            WHERE
                replies.parent_reply_key = :parent_reply_id     
        SQL
        parent_replies.map { |reply_datum| Reply.new(reply_datum)  }
    end

    def self.find_by_user_id(author_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT
                *
            FROM
                replies
            WHERE
                author_id = ?
        SQL
        return nil if replies.length < 1
        replies.map{ |reply_datum| Reply.new(reply_datum) }
    end

    def self.find_by_question_id(question_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT 
                *
            FROM
                replies
            WHERE
                question_id = ?
        SQL
        return nil if replies.length < 1
        replies.map{ |reply_datum| Reply.new(reply_datum) }
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @parent_reply_key = options['parent_reply_key']
        @author_id = options['author_id']
        @body = options['body']
    end

    def save
        if @id
            QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_reply_key, @author_id, @body, @id )
                UPDATE
                    replies
                SET
                    question_id = ?,
                    parent_reply_key = ?,
                    author_id = ?,
                    body = ?
                WHERE
                    id = ?
            SQL
        else
            QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_reply_key, @author_id, @body)
                INSERT INTO
                    replies(question_id, parent_reply_key, author_id, body)
                VALUES
                    (?, ?, ?, ?)
            SQL
            @id = QuestionsDatabase.instance.last_insert_row_id
        end
        self
    end

    def author
        User.find_by_id(author_id)
    end
    
    def question
        Question.find_by_id(question_id)
    end

    def parent_reply
        Reply.find_by_id(parent_reply_key)
    end

    def child_replies
        Reply.find_by_parent_id(id)
    end
end