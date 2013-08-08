class Wiki < ActiveRecord::Base
  has_many :wikis
  has_many :files, class_name: 'WikiFile'
  belongs_to :wiki
  belongs_to :event, :counter_cache => true

  attr_accessible :content, :name, :wiki_id, :event_id, :title, :main, :event_name,
      :files_attributes
  accepts_nested_attributes_for :files, allow_destroy: true

  validates_presence_of :name, :event, :title
  validates_uniqueness_of :name, scope: :event_id

  before_save :correct_name, :clear_mains

  def event_name=(e) end

  def correct_name
    if self.name
      self.name.gsub! ' ', '-'
      self.name.gsub! /[^\w_\-]/i, ''
    end
  end

  def event_name
    event.name if event
  end

  def clear_mains
    if self.main
      ws = self.event.wikis.where(main: true)
      ws = ws.where('id <> ?', self.id) if self.id
      ws.update_all(main: false)
    end
  end
end
