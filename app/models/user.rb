class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :shops, dependent: :nullify
  has_many :listings, dependent: :nullify
  belongs_to :shop, optional: true

  def shopowner?
    role == 'shopowner'
  end

  def service_provider?
    role == 'service_provider'
  end

  def shopworker?
    role == 'shopworker'
  end

  def superadmin?
    role == 'superadmin'
  end

  def full_name
    [first_name, last_name].select(&:present?).join(' ').presence || email
  end
end
