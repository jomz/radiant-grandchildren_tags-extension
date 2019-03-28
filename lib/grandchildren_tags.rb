module GrandchildrenTags
  include Radiant::Taggable

  desc %{
    Renders the contained elements only if the current contextual page has one or
    more grandchild pages.  The @status@ attribute limits the status of found child pages
    to the given status, the default is @"published"@. @status="all"@ includes all
    non-virtual pages regardless of status.

    *Usage:*
    
    <pre><code><r:if_grandchildren [status="published"]>...</r:if_grandchildren></code></pre>
  }
  tag "if_grandchildren" do |tag|
    tag.locals.parent_ids = tag.locals.page.children.map(&:id)
    options = aggregate_children(tag)
    tag.expand if Page.count(options) > 0
  end

  desc %{
    Renders the contained elements only if the current contextual page has no grandchildren.
    The @status@ attribute limits the status of found child pages to the given status,
    the default is @"published"@. @status="all"@ includes all non-virtual pages
    regardless of status.

    *Usage:*
    
    <pre><code><r:unless_grandchildren [status="published"]>...</r:unless_grandchildren></code></pre>
  }
  tag "unless_grandchildren" do |tag|
    tag.locals.parent_ids = tag.locals.page.children.map(&:id)
    options = aggregate_children(tag)
    tag.expand unless Page.count(options) > 0
  end

  desc %{
    Gives access to a page's grandchildren.

    *Usage:*
  
    <pre><code><r:grandchildren>...</r:grandchildren></code></pre>
  }
  tag 'grandchildren' do |tag|
    tag.locals.parent_ids = tag.locals.page.children.map(&:id)
    tag.expand
  end

  desc %{
    Renders the total number of grandchildren.
  }
  tag 'grandchildren:count' do |tag|
    options = aggregate_children(tag)
    Page.count(options)
  end

  desc %{
    Returns the first grandchild. Inside this tag all page attribute tags are mapped to
    the first child. Takes the same ordering options as @<r:children:each>@.

    *Usage:*
  
    <pre><code><r:grandchildren:first>...</r:grandchildren:first></code></pre>
  }
  tag 'grandchildren:first' do |tag|
    options = aggregate_children(tag)
    grandchildren = Page.find(:all, options)
    if first = grandchildren.first
      tag.locals.page = first
      tag.expand
    end
  end

  desc %{
    Returns the last grandchild. Inside this tag all page attribute tags are mapped to
    the last grandchild. Takes the same ordering options as @<r:children:each>@.

    *Usage:*
  
    <pre><code><r:grandchildren:last>...</r:grandchildren:last></code></pre>
  }
  tag 'grandchildren:last' do |tag|
    options = aggregate_children(tag)
    grandchildren = Page.find(:all, options)
    if last = grandchildren.last
      tag.locals.page = last
      tag.expand
    end
  end

  desc %{
    Cycles through each of the grandchildren. Inside this tag all page attribute tags
    are mapped to the current grandchild page.
  
    Supply @paginated="true"@ to paginate the displayed list. will_paginate view helper
    options can also be specified, including @per_page@, @previous_label@, @next_label@,
    @class@, @separator@, @inner_window@ and @outer_window@.

    *Usage:*
  
    <pre><code><r:grandchildren:each [offset="number"] [limit="number"]
     [by="published_at|updated_at|created_at|slug|title"]
     [order="asc|desc"] 
     [status="draft|reviewed|published|hidden|all"]
     [paginated="true"]
     [per_page="number"]
     >
     ...
    </r:children:each>
    </code></pre>
  }
  tag 'grandchildren:each' do |tag|
    render_children_with_pagination(tag, :aggregate => true)
  end

  desc %{
    The pagination tag is not usually called directly. Supply paginated="true" when you display a list and it will
    be automatically display only the current page of results, with pagination controls at the bottom.

    *Usage:*
  
    <pre><code><r:grandchildren:each paginated="true" per_page="50" container="false" previous_label="foo" next_label="bar">
      <r:child>...</r:child>
    </r:grandchildren:each>
    </code></pre>
  }
  tag 'pagination' do |tag|
    if tag.locals.paginated_list
      will_paginate(tag.locals.paginated_list, will_paginate_options(tag))
    end
  end

  desc %{
    Page attribute tags inside of this tag refer to the current grandchild. This is occasionally
    useful if you are inside of another tag (like &lt;r:find&gt;) and need to refer back to the
    current child.

    *Usage:*
  
    <pre><code><r:grandchildren:each>
      <r:child>...</r:child>
    </r:grandchildren:each>
    </code></pre>
  }
  tag 'grandchildren:each:child' do |tag|
    tag.locals.page = tag.locals.child
    tag.expand
  end

  desc %{
    Renders the tag contents only if the current page is the first child in the context of
    a grandchildren:each tag
  
    *Usage:*
  
    <pre><code><r:grandchildren:each>
      <r:if_first >
        ...
      </r:if_first>
    </r:grandchildren:each>
    </code></pre>
  
  }
  tag 'grandchildren:each:if_first' do |tag|
    tag.expand if tag.locals.first_child
  end


  desc %{
    Renders the tag contents unless the current page is the first child in the context of
    a grandchildren:each tag
  
    *Usage:*
  
    <pre><code><r:grandchildren:each>
      <r:unless_first >
        ...
      </r:unless_first>
    </r:grandchildren:each>
    </code></pre>
  
  }
  tag 'grandchildren:each:unless_first' do |tag|
    tag.expand unless tag.locals.first_child
  end

  desc %{
    Renders the tag contents only if the current page is the last child in the context of
    a grandchildren:each tag
  
    *Usage:*
  
    <pre><code><r:grandchildren:each>
      <r:if_last >
        ...
      </r:if_last>
    </r:grandchildren:each>
    </code></pre>
  
  }
  tag 'grandchildren:each:if_last' do |tag|
    tag.expand if tag.locals.last_child
  end


  desc %{
    Renders the tag contents unless the current page is the last child in the context of
    a grandchildren:each tag
  
    *Usage:*
  
    <pre><code><r:grandchildren:each>
      <r:unless_last >
        ...
      </r:unless_last>
    </r:grandchildren:each>
    </code></pre>
  
  }
  tag 'grandchildren:each:unless_last' do |tag|
    tag.expand unless tag.locals.last_child
  end

  desc %{
    Renders the tag contents only if the contents do not match the previous header. This
    is extremely useful for rendering date headers for a list of child pages.

    If you would like to use several header blocks you may use the @name@ attribute to
    name the header. When a header is named it will not restart until another header of
    the same name is different.

    Using the @restart@ attribute you can cause other named headers to restart when the
    present header changes. Simply specify the names of the other headers in a semicolon
    separated list.

    *Usage:*
  
    <pre><code><r:grandchildren:each>
      <r:header [name="header_name"] [restart="name1[;name2;...]"]>
        ...
      </r:header>
    </r:grandchildren:each>
    </code></pre>
  }
  tag 'grandchildren:each:header' do |tag|
    previous_headers = tag.locals.previous_headers
    name = tag.attr['name'] || :unnamed
    restart = (tag.attr['restart'] || '').split(';')
    header = tag.expand
    unless header == previous_headers[name]
      previous_headers[name] = header
      unless restart.empty?
        restart.each do |n|
          previous_headers[n] = nil
        end
      end
      header
    end
  end
  
end
