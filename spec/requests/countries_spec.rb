require 'spec_helper'

describe 'countries requests', :js => true do
  subject { page }

  shared_examples_for( 'weight_slider' ) {
    it ( 'should have country data loading screen' ) {
      should have_css '.score-keeper-loader', visible: false
    }

    it ( 'should have weight_slider link' ) {
      should have_selector( 'a.toggle-weight-sliders' );
      should have_css '#weight-sliders.hidden', visible: false
    }

    describe ( 'click toggle-weight-sliders' ) {
      before {
        page.execute_script( %q[$('.toggle-weight-sliders').click( )] );
      }

      it ( 'should show weight-sliders' ) {
        snap
        find( '#weight-sliders' ).visible?.should be_true
        should have_css( '#weight-sliders .weight-slider', count: 3 )
      }

      describe ( 'slide slider' ) {
        before {
          page.execute_script( %q[$('#slider-1').val( 0.5, true )] )
        }

        it {
          snap
          current_url.should match 'ds_pct_inet=0.5'
        }
      }

      it ( 'should hide weight-sliders' ) {
        page.execute_script( %q[$('.toggle-weight-sliders').click( )] );
        should have_css( '#weight-sliders', count: 0 );
      }
    }
  }

  describe 'get /countries index' do
    before {
      visit( countries_path )
    }

    it {
      should have_title( 'countries @ Internet Monitor' )
    }

    it_should_behave_like( 'weight_slider' );
  end


  shared_examples_for( 'category_selector' ) {
    it ( 'should have category selector links' ) {
      should have_selector( ".category-selector a[href*='#{category_country_path(country, :category_slug => "access")}']" );
      should have_selector( ".category-selector a[href*='#{category_country_path(country, :category_slug => "control")}']" );
      should have_selector( ".category-selector a[href*='#{category_country_path(country, :category_slug => "activity")}']" );
    }
  }

  describe( "get /countries/:id" ) do
    context ( 'with normal country' ) {
      let ( :country ) { Country.find_by_iso3_code( 'IRN' ) }

      before { visit country_path( country ) }

      it {
        should have_title( "#{country.name.downcase} @ Internet Monitor" )
      }

      it {
        should have_selector 'h1', text: country.name
      }

      it_should_behave_like( 'weight_slider' );

      it_should_behave_like( 'category_selector' );
      it ( 'should not have any category' ) {
        should_not have_selector( ".category-selector a.selected" );
      }

      it ( 'should not have indicators' ) {
        should_not have_selector( '.country .indicators,.country .url-lists,.country .html-blocks,.country .images' );
      }

      it {
        should have_css '.score-pill'
      }

      describe 'click user score in pill' do
        before {
          page.execute_script( %q[$('a.user-score').click( )] );
          #click_link 'a.user-score'
        }

        it {
          find( '#weight-sliders' ).visible?.should be_true;
        }

      end
    }
  end

  describe( "get /countries/:id/access" ) do
    context ( 'with normal country' ) {
      let ( :country ) { Country.find_by_iso3_code( 'IRN' ) }
      let ( :category ) { Category.find_by_name( 'Access' ) }

      before {
        visit category_country_path(country, :category_slug => 'access')
      }

      it {
        should have_title( "#{country.name.downcase} access @ Internet Monitor" )
      }

      it_should_behave_like( 'weight_slider' );

      it_should_behave_like( 'category_selector' );
      it ( 'should have category selected' ) {
        should have_selector( ".category-selector a[href*='#{category_country_path(country, :category_slug => "access")}'].selected" );
      }
    }

    context ( 'with country missing access CMS page' ) {
      let ( :country ) { Country.find_by_iso3_code( 'USA' ) }
      let ( :category ) { Category.find_by_name( 'Access' ) }

      before {
        visit category_country_path( country, category_slug: 'access' )
      }

      it {
        should have_title( "#{country.name.downcase} access @ Internet Monitor" )
      }
    }
  end

  describe 'get /countries/:id/control' do
    let ( :country ) { Country.find_by_iso3_code( 'IRN' ) }
    let ( :category ) { Category.find_by_name( 'Control' ) }

    before {
      visit category_country_path( country, :category_slug => 'control' )
    }

    it {
      should have_title( "#{country.name.downcase} control @ Internet Monitor" )
    }

    it_should_behave_like( 'weight_slider' );

    it_should_behave_like( 'category_selector' );
    it ( 'should have category selected' ) {
      should have_selector( ".category-selector a[href*='#{category_country_path(country, :category_slug => "control")}'].selected" );
    }
  end

  describe( "get /countries/:id/activity" ) do
    let ( :country ) { Country.find_by_iso3_code( 'IRN' ) }
    let ( :category ) { Category.find_by_name( 'Activity' ) }

    before {
      visit category_country_path( country, :category_slug => 'activity' )
    }

    it {
      should have_title( "#{country.name.downcase} activity @ Internet Monitor" )
    }

    it_should_behave_like( 'weight_slider' );

    it_should_behave_like( 'category_selector' );
    it ( 'should have category selected' ) {
      should have_selector( ".category-selector a[href*='#{category_country_path(country, :category_slug => "activity")}'].selected" );
    }
  end

end
