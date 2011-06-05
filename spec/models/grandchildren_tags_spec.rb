require File.dirname(__FILE__) + '/../spec_helper'

describe "Grandchildren Tags" do
  dataset :home_page, :users_and_pages
  
  it '<r:if_grandchildren> should render the contained block if the current page has child pages' do
    pages(:home).should render('<r:if_grandchildren>true</r:if_grandchildren>').as('true')
    pages(:childless).should render('<r:if_grandchildren>true</r:if_grandchildren>').as('')
  end

  it '<r:unless_grandchildren> should render the contained block if the current page has no child pages' do
    pages(:home).should render('<r:unless_grandchildren>true</r:unless_grandchildren>').as('')
    pages(:childless).should render('<r:unless_grandchildren>true</r:unless_grandchildren>').as('true')
  end

  describe "<r:grandchildren:each>" do
    it "should iterate through the grandchildren of the current page" do
      pages(:parent).should render('<r:grandchildren:each:title />').as('Grandchild')
      pages(:parent).should render('<r:grandchildren:each><r:parent:slug />/<r:slug /></r:grandchildren:each>').as('child/grandchild')
    end

    it 'should not list draft pages' do
      pages(:home).should render(page_grandchildren_each_tags(%{by="title"})).as('a article article-2 article-3 article-4 b c child child-2 child-3 d e f g guests h i j ')
    end

    it 'should include draft pages with status="all"' do
      pages(:home).should render(page_grandchildren_each_tags(%{status="all" by="slug"})).as('a article article-2 article-3 article-4 b c child child-2 child-3 d draft draft-article e f g guests h i j ')
    end

    it "should include draft pages by default on the dev host" do
      pages(:home).should render(page_grandchildren_each_tags(%{by="slug"})).as('a article article-2 article-3 article-4 b c child child-2 child-3 d draft draft-article e f g guests h i j ').on('dev.site.com')
    end

    it 'should not list draft pages on dev.site.com when Radiant::Config["dev.host"] is set to something else' do
      Radiant::Config['dev.host'] = 'preview.site.com'
      pages(:home).should render(page_grandchildren_each_tags(%{by="title"})).as('a article article-2 article-3 article-4 b c child child-2 child-3 d e f g guests h i j ').on('dev.site.com')
    end

    describe 'with paginated="true"' do
      it 'should limit correctly the result set' do
        page(:home)
        page.pagination_parameters = {:page => 1, :per_page => 20}
        page.should render(page_grandchildren_each_tags(%{paginated="true"})).as('article article-2 article-3 article-4 a b c d e f g h i j child child-3 child-2 guests ')
        page.should render(page_grandchildren_each_tags(%{paginated="true" per_page="2"})).not_matching(/article article-2 article-3/)
      end
      it 'should display a pagination control block' do
        page(:home)
        page.pagination_parameters = {:page => 1, :per_page => 1}
        page.should render(page_grandchildren_each_tags(%{ paginated="true"})).matching(/div class="pagination"/)
      end
      it 'should link to the correct paginated page' do
        page(:home)
        page.pagination_parameters = {:page => 1, :per_page => 1}
        page.should render('<r:find path="/"><r:grandchildren:each paginated="true"><r:slug /> </r:grandchildren:each></r:find>').matching(%r{href="/\?page=2})
      end
      it 'should pass through selected will_paginate parameters' do
        page(:home)
        page.pagination_parameters = {:page => 5, :per_page => 1}
        page.should render(page_grandchildren_each_tags(%{ paginated="true" separator="not that likely a choice"})).matching(/not that likely a choice/)
        page.should render(page_grandchildren_each_tags(%{ paginated="true" previous_label="before"})).matching(/before/)
        page.should render(page_grandchildren_each_tags(%{ paginated="true" next_label="after"})).matching(/after/)
        page.should render(page_grandchildren_each_tags(%{ paginated="true" inner_window="1" outer_window="0"})).not_matching(/\?p=2/)
      end
    end
  
    it 'should error with invalid "limit" attribute' do
      message = "`limit' attribute must be a positive number"
      pages(:home).should render(page_grandchildren_each_tags(%{limit="a"})).with_error(message)
      pages(:home).should render(page_grandchildren_each_tags(%{limit="-10"})).with_error(message)
    end

    it 'should error with invalid "offset" attribute' do
      message = "`offset' attribute must be a positive number"
      pages(:home).should render(page_grandchildren_each_tags(%{offset="a"})).with_error(message)
      pages(:home).should render(page_grandchildren_each_tags(%{offset="-10"})).with_error(message)
    end

    it 'should error with invalid "by" attribute' do
      message = "`by' attribute of `each' tag must be set to a valid field name"
      pages(:home).should render(page_grandchildren_each_tags(%{by="non-existant-field"})).with_error(message)
    end

    it 'should error with invalid "order" attribute' do
      message = %{`order' attribute of `each' tag must be set to either "asc" or "desc"}
      pages(:home).should render(page_grandchildren_each_tags(%{order="asdf"})).with_error(message)
    end

    it "should limit the number of children when given a 'limit' attribute" do
      pages(:home).should render(page_grandchildren_each_tags(%{limit="5"})).as('article article-2 article-3 article-4 a ')
    end

    it "should limit and offset the children when given 'limit' and 'offset' attributes" do
      pages(:home).should render(page_grandchildren_each_tags(%{offset="3" limit="5"})).as('article-4 a b c d ')
    end

    it "should sort by the 'by' attribute" do
      pages(:home).should render(page_grandchildren_each_tags(%{by="breadcrumb"})).as('f article article-2 article-3 article-4 e d child child-2 child-3 c b a j guests i h g ')
    end

    it "should sort by the 'by' attribute according to the 'order' attribute" do
      pages(:home).should render(page_grandchildren_each_tags(%{by="breadcrumb" order="desc"})).as('g h i guests j a b c child-3 child-2 child d e article-4 article-3 article-2 article f ')
    end

    describe 'with "status" attribute' do
      it "set to 'draft' should list only children with 'draft' status" do
        pages(:home).should render(page_grandchildren_each_tags(%{status="draft"})).as('draft draft-article ')
      end

      it "set to 'published' should list only children with 'draft' status" do
        pages(:home).should render(page_grandchildren_each_tags(%{status="published"})).as('article article-2 article-3 article-4 a b c d e f g h i j child child-3 child-2 guests ')
      end

      it "set to an invalid status should render an error" do
        pages(:home).should render(page_grandchildren_each_tags(%{status="askdf"})).with_error("`status' attribute of `each' tag must be set to a valid status")
      end
    end
  end

  describe "<r:grandchildren:each:if_first>" do
    it "should render for the first child" do
      tags = '<r:grandchildren:each><r:if_first>FIRST:</r:if_first><r:slug /> </r:grandchildren:each>'
      expected = "FIRST:article article-2 article-3 article-4 a b c d e f g h i j child child-3 child-2 guests "
      page(:home).should render(tags).as(expected)
    end
  end

  describe "<r:grandchildren:each:unless_first>" do
    it "should render for all but the first child" do
      tags = '<r:grandchildren:each><r:unless_first>NOT-FIRST:</r:unless_first><r:slug /> </r:grandchildren:each>'
      expected = "article NOT-FIRST:article-2 NOT-FIRST:article-3 NOT-FIRST:article-4 NOT-FIRST:a NOT-FIRST:b NOT-FIRST:c NOT-FIRST:d NOT-FIRST:e NOT-FIRST:f NOT-FIRST:g NOT-FIRST:h NOT-FIRST:i NOT-FIRST:j NOT-FIRST:child NOT-FIRST:child-3 NOT-FIRST:child-2 NOT-FIRST:guests "
      page(:home).should render(tags).as(expected)
    end
  end

  describe "<r:grandchildren:each:if_last>" do
    it "should render for the last child" do
      tags = '<r:grandchildren:each><r:if_last>LAST:</r:if_last><r:slug /> </r:grandchildren:each>'
      expected = "article article-2 article-3 article-4 a b c d e f g h i j child child-3 child-2 LAST:guests "
      page(:home).should render(tags).as(expected)
    end
  end

  describe "<r:grandchildren:each:unless_last>" do
    it "should render for all but the last child" do
      tags = '<r:grandchildren:each><r:unless_last>NOT-LAST:</r:unless_last><r:slug /> </r:grandchildren:each>'
      expected = "NOT-LAST:article NOT-LAST:article-2 NOT-LAST:article-3 NOT-LAST:article-4 NOT-LAST:a NOT-LAST:b NOT-LAST:c NOT-LAST:d NOT-LAST:e NOT-LAST:f NOT-LAST:g NOT-LAST:h NOT-LAST:i NOT-LAST:j NOT-LAST:child NOT-LAST:child-3 NOT-LAST:child-2 guests "
      page(:home).should render(tags).as(expected)
    end
  end

  describe "<r:grandchildren:each:header>" do
    it "should render the header when it changes" do
      tags = '<r:grandchildren:each><r:header>[<r:date format="%b/%y" />] </r:header><r:slug /> </r:grandchildren:each>'
      expected = "[Dec/00] article [Feb/01] article-2 article-3 [Mar/01] article-4 [Jun/11] a b c d e f g h i j child child-3 child-2 guests "
      page(:home).should render(tags).as(expected)
    end

    it 'with "name" attribute should maintain a separate header' do
      tags = %{<r:grandchildren:each><r:header name="year">[<r:date format='%Y' />] </r:header><r:header name="month">(<r:date format="%b" />) </r:header><r:slug /> </r:grandchildren:each>}
      expected = "[2000] (Dec) article [2001] (Feb) article-2 article-3 (Mar) article-4 [2011] (Jun) a b c d e f g h i j child child-3 child-2 guests "
      page(:home).should render(tags).as(expected)
    end

    it 'with "restart" attribute set to one name should restart that header' do
      tags = %{<r:grandchildren:each><r:header name="year" restart="month">[<r:date format='%Y' />] </r:header><r:header name="month">(<r:date format="%b" />) </r:header><r:slug /> </r:grandchildren:each>}
      expected = "[2000] (Dec) article [2001] (Feb) article-2 article-3 (Mar) article-4 [2011] (Jun) a b c d e f g h i j child child-3 child-2 guests "
      page(:home).should render(tags).as(expected)
    end

    it 'with "restart" attribute set to two names should restart both headers' do
      tags = %{<r:grandchildren:each><r:header name="year" restart="month;day">[<r:date format='%Y' />] </r:header><r:header name="month" restart="day">(<r:date format="%b" />) </r:header><r:header name="day"><<r:date format='%d' />> </r:header><r:slug /> </r:grandchildren:each>}
      expected = "[2000] (Dec) <01> article [2001] (Feb) <09> article-2 <24> article-3 (Mar) <06> article-4 [2011] (Jun) <05> a b c d e f g h i j child child-3 child-2 guests "
      page(:home).should render(tags).as(expected)
    end
  end

  describe "<r:grandchildren:count>" do
    it 'should render the number of grandchildren of the current page' do
      page(:home).should render('<r:grandchildren:count />').as('18')
    end

    it "should accept the same scoping conditions as <r:children:each>" do
      page(:home).should render('<r:grandchildren:count status="all" />').as('20')
      page(:home).should render('<r:grandchildren:count status="draft" />').as('2')
      page(:home).should render('<r:grandchildren:count status="hidden" />').as('0')
    end
  end

  describe "<r:grandchildren:first>" do
    it 'should render its contents in the context of the first grandchild page' do
      page(:parent).should render('<r:grandchildren:first:title />').as('Grandchild')
    end

    it 'should accept the same scoping attributes as <r:children:each>' do
      page(:home)
      page.should render(page_grandchildren_first_tags).as('article')
      page.should render(page_grandchildren_first_tags(%{limit="5"})).as('article')
      page.should render(page_grandchildren_first_tags(%{offset="3" limit="5"})).as('article-4')
      page.should render(page_grandchildren_first_tags(%{order="desc" by="published_at"})).as('guests')
      page.should render(page_grandchildren_first_tags(%{by="breadcrumb"})).as('f')
      page.should render(page_grandchildren_first_tags(%{by="breadcrumb" order="desc"})).as('g')
    end

    it "should render nothing when no children exist" do
      page(:first).should render('<r:grandchildren:first:title />').as('')
    end
  end

  describe "<r:grandchildren:last>" do
    it 'should render its contents in the context of the last child page' do
      pages(:home).should render('<r:grandchildren:last:title />').as('Guests')
    end

    it 'should accept the same scoping attributes as <r:children:each>' do
      page(:home)
      page.should render(page_grandchildren_last_tags).as('guests')
      page.should render(page_grandchildren_last_tags(%{limit="5"})).as('a')
      page.should render(page_grandchildren_last_tags(%{offset="3" limit="5"})).as('d')
      page.should render(page_grandchildren_last_tags(%{order="desc" by="published_at"})).as('article')
      page.should render(page_grandchildren_last_tags(%{by="breadcrumb"})).as('g')
      page.should render(page_grandchildren_last_tags(%{by="breadcrumb" order="desc"})).as('f')
    end

    it "should render nothing when no grandchildren exist" do
      page(:first).should render('<r:grandchildren:last:title />').as('')
    end
  end
  
  private

    def page(symbol = nil)
      if symbol.nil?
        @page ||= pages(:assorted)
      else
        @page = pages(symbol)
      end
    end

    def page_grandchildren_each_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:grandchildren:each#{attr}><r:slug /> </r:grandchildren:each>"
    end

    def page_grandchildren_first_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:grandchildren:first#{attr}><r:slug /></r:grandchildren:first>"
    end

    def page_grandchildren_last_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:grandchildren:last#{attr}><r:slug /></r:grandchildren:last>"
    end
end