class RemoveCachedScopedLikeVotesFromPosts < ActiveRecord::Migration[6.1]
  def change
    remove_column :posts, :cached_scoped_like_votes_total, :integer
    remove_column :posts, :cached_scoped_like_votes_score, :integer
    remove_column :posts, :cached_scoped_like_votes_up, :integer
    remove_column :posts, :cached_scoped_like_votes_down, :integer
    remove_column :posts, :cached_weighted_like_score, :integer
    remove_column :posts, :cached_weighted_like_total, :integer
    remove_column :posts, :cached_weighted_like_average, :float
  end
end
