class AddCachedScopedLikeVotesToPosts < ActiveRecord::Migration[6.1]
  def change
    change_table :posts do |t|
      t.integer :cached_scoped_like_votes_total, default: 0
      t.integer :cached_scoped_like_votes_score, default: 0
      t.integer :cached_scoped_like_votes_up, default: 0
      t.integer :cached_scoped_like_votes_down, default: 0
      t.integer :cached_weighted_like_score, default: 0
      t.integer :cached_weighted_like_total, default: 0
      t.float :cached_weighted_like_average, default: 0.0

      # calculate the existing votes
      # Post.find_each { |p| p.update_cached_votes("like") }
    end
  end
end
