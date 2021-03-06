module Optimadmin
  class AdditionalContentPresenter < Optimadmin::BasePresenter
    presents :additional_content

    def title
      additional_content.title
    end

    def toggle_title
      inline_detail_toggle_link(area)
    end

    def area
      additional_content.area
    end

    def content
      h.raw additional_content.content
    end
  end
end
