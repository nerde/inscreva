class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
      :trackable, :validatable

  has_many :subscriptions, dependent: :destroy
  has_many :delegations, dependent: :destroy

  def self.not_subscribers
    where('users.id in (select distinct user_id from delegations) or ' +
        'users.id not in (select distinct user_id from subscriptions)')
  end

  def self.by_name(name)
    where(arel_table[:name].matches("%#{name}%"))
  end

  def self.search(term)
    term = "%#{term}%"
    where(arel_table[:name].matches(term).or(arel_table[:email].matches(term)))
  end
end
