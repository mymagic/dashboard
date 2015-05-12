module Taggable
  extend ActiveSupport::Concern

  included do
    attr_accessor :new_tags
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings, class_name: "#{ name }Tag"

    scope :tagged_with, ->(tag) { joins(:tags).where(tags: { id: tag }) }

    after_save :set_tags

    def self.tags_class
      "#{ name }Tag".constantize
    end
  end

  def add_tag(name)
    params = { name: name, community: community }
    tags_class = self.class.tags_class
    tag = tags_class.find_by(params) || tags_class.create(params)
    tags.push(tag) unless tags.include? tag
    tag
  end

  def remove_tag(name)
    existing_tag = tags.where(name: name)
    return unless existing_tag.present?
    tags.delete(existing_tag).map(&:destroy_if_orphaned!)
  end

  def tag_list
    (@new_tags || tags.pluck(:name)).join(',')
  end

  def tag_list=(tag_string)
    @new_tags = tag_string.split(',').map(&:strip).uniq.reject(&:blank?)
  end

  protected

  def set_tags
    return unless @new_tags.present?
    existing_tags = tags.pluck(:name)
    (existing_tags - @new_tags).each { |name| (name) }
    @new_tags.each { |name| add_tag(name) }
  end
end
