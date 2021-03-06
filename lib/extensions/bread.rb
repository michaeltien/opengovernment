module SimpleNavigation
  module Renderer
    # Renders an ItemContainer as a <div> element and its containing items as <a> elements.
    # It only renders 'selected' elements.
    #
    # By default, the renderer sets the item's key as dom_id for the rendered <a> element unless the config option <tt>autogenerate_item_ids</tt> is set to false.
    # The id can also be explicitely specified by setting the id in the html-options of the 'item' method in the config/navigation.rb file.
    # The ItemContainer's dom_class and dom_id are applied to the surrounding <div> element.
    #
    class Bread < SimpleNavigation::Renderer::Base
      
      def render(item_container)
        a_tags = a_tags(item_container)
        a_tags.join(join_with).html_safe
      end

      protected

      def a_tags(item_container, level = 0)
        i = 0
        item_container.items.inject([]) do |list, item|
          ops = item.html_options.except(:id)

          Rails.logger.debug "item: #{item.name}\nselected? #{item.selected?} sub? #{include_sub_navigation?(item)}\n"

          # One item at every nav level that leads to where we are now is considered "selected"
          if item.selected?
            

            # Link to all items that with children (but not to the current page)
            if include_sub_navigation?(item)
              list_item = link_to(content_tag(:span, item.name), item.url, { :method => item.method }.merge(item.html_options.except(:class, :id)))
            else
              list_item = content_tag(:span, item.name, :class => 'current')
            end

            if i == 0 && level == 0
              ops[:class].concat(' first')
              list_item << link_to('', '#', :id => 'secondary_dropdown', :class => 'dropdown')

              secondary_items = ''.html_safe
              item_container.items.each do |secondary_item|
                secondary_items << content_tag(:li, link_to(content_tag(:span, secondary_item.name), secondary_item.url))
              end

              list_item << content_tag(:ul, secondary_items, :class => 'secondary-select')

            end

            list << content_tag(:li, list_item, ops)

            # Recurse if necessary
            if include_sub_navigation?(item)
              list.concat a_tags(item.sub_navigation, level + 1)
            end
            i += 1
          end
          list
        end
      end

      def join_with
        @join_with ||= options[:join_with] || " "
      end
    end
    
  end
end