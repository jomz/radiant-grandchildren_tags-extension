class GrandchildrenDataset < Dataset::Base
  uses :home_page, :pages
    
  helpers do
    describe "Archive index page", :shared => true do
      it "should render <r:archive:children:first /> as unimplemented" do
        @page.should render('<r:archive:children:first><r:slug /></r:archive:children:first>').as('unimplemented')
      end

      it "should render <r:archive:children:last /> as unimplemented" do
        @page.should render('<r:archive:children:last><r:slug /></r:archive:children:last>').as('unimplemented')
      end

      it "should <r:archive:children:count /> as unimplemented" do
        @page.should render('<r:archive:children:count><r:slug /></r:archive:children:count>').as('unimplemented')
      end
      
      it "should render the <r:archive:year /> tag" do
        @page.should render("<r:archive:year />").as("2000").on("/archive/2000/")
      end
      
      it "should render the <r:archive:month /> tag" do
        @page.should render("<r:archive:month />").as("June").on("/archive/2000/06/")
      end
      
      it "should render the <r:archive:day /> tag" do
        @page.should render('<r:archive:day />').as("9").on('/archive/2000/06/09/')
      end
      
      it "should render the <r:archive:day_of_week /> tag" do
        @page.should render('<r:archive:day_of_week />').as('Friday').on("/archive/2000/06/09/")
      end
    end
  end
end