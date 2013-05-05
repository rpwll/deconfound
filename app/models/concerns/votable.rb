module Votable
	extend ActiveSupport::Concern

	included do
		has_many :votes, as: :votable
	end

	# Calculate the score for an individual votable
	def calculate_score
		self.votes_count ||= 0
		time_elapsed = (Time.now - self.created_at) / (60 * 60)
		self.score = (self.votes_count / time_elapsed ** 1.8).real
	end

	# Calculate the score for an individual votable and update its database
	# record with that score
	def calculate_score!
		self.calculate_score
		self.save
	end

	module ClassMethods
		# Recalculate the score of every single votable, this could be made
		# _a lot_ more efficient
		def recalculate_all_scores!
			self.find_each do |votable|
				votable.calculate_score!
			end
		end

		# Recalculate only the scores of the top 50 questions and answers
		def recalculate_popular_scores!
			self.order('score DESC').limit(50).each do |votable|
				votable.calculate_score!
			end
		end
	end
end