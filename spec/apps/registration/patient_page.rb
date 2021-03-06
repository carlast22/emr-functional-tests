class Registration::PatientPage < Page

    GIVEN_NAME = 'givenName'
    FAMILY_NAME = 'familyName'
    VILLAGE = 'cityVillage'
    GENDER = 'gender'
    AGE_YEARS = 'ageYears'

    def fill(patient)
        fill_in GIVEN_NAME, :with => patient[:given_name]
        fill_in FAMILY_NAME, :with => patient[:family_name]
        select patient[:gender], :from => GENDER
        fill_in AGE_YEARS, :with => patient[:age][:years]
        fill_in VILLAGE, :with => patient[:village] if patient.has_key? :village
        fill_in "Address Line", :with => patient[:address_line] if patient.has_key? :address_line
        fill_in 'House No., Street', :with => patient[:house_number] if patient.has_key? :house_number
        fill_in 'Gram Panchayat', :with => patient[:gram_panchayat] if patient.has_key? :gram_panchayat
        fill_in 'Caste', :with => patient[:caste] if patient.has_key? :caste
        select(patient[:class], :from => "class") if patient.has_key? :class
        select(patient[:education_details], :from => "education") if patient.has_key? :education_details
        select(patient[:occupation], :from => "occupation") if patient.has_key? :occupation
        if (patient.has_key? :additional_info) && (patient[:additional_info] == "true")
        click_link_with_text "Additional Patient Information"
        fill_in 'debt (in Rs)', :with => patient[:debt] if patient.has_key? :debt
        fill_in 'Distance From Center (in km)', :with => patient[:distanceFromCenter] if patient.has_key? :distanceFromCenter
        check 'isUrban'
        select(patient[:cluster], :from => "cluster") if patient.has_key? :cluster
        select(patient[:ration_card], :from => "RationCard") if patient.has_key? :ration_card
        select(patient[:family_income], :from => "familyIncome") if patient.has_key? :family_income
        end
        self
    end

    def start_visit_type(type)
        start_visit "Start #{type} visit"
    end

    def enter_visit_page
        start_visit "Enter Visit Details"
        wait_for_overlay_to_be_hidden
    end

    def start_visit(text)
        click_on text
        wait_for_element_with_xpath_to_be_visible('//button[text()="Close Visit"]')
    end

    def fill_village_and_save(village)
        fill_village(village)
        wait_for_element_to_load("cityVillage")
        save
    end

    def fill_village(village)
        fill_in VILLAGE, :with => village
    end

    def fill_age(age)
        fill_in AGE_YEARS, :with => age
    end

    def save()
        sleep 1
        click_on("Save")
        wait_for_overlay_to_be_hidden
        # wait_for_element_with_css_with_text('strong','Paper')
    end

    def verify_village(village)
       field_value= find_by_id("cityVillage").value
       expect(field_value).to eq(village)
    end

    def find_by_id(id)
        return find('[id="'+id+'"]', :match => :prefer_exact)
    end

    def get_patient_id
        sleep 1
        return find('legend.registraion_legend span.mylegend span',:match => :first).text.gsub(/[A-Z]/,'')
        # return find('legend.registraion_legend span.mylegend span',:match => :first).text.gsub(/[:alnum:]/,'')

    end

    def verify_update_village(village)
      fill_village_and_save(village)
      verify_village(village)
    end

    def verify_update_age(age)
        click_link_with_text('Not Assigned')

        fill_age(age)
        save
        verify(AGE_YEARS, age.to_s)
    end

    def verify_all_fields(patient)
      wait_for_element_to_load(GIVEN_NAME) #looking for verification before page loads
      verify(GIVEN_NAME, patient[:given_name])
      verify(FAMILY_NAME, patient[:family_name])
      patient[:gender]=="Male" ? verify(GENDER, "M") : verify(GENDER, "F")
      verify(AGE_YEARS, patient[:age][:years])
      verify(VILLAGE, patient[:village])
    end

    def verify(identifier, value)
      field_value= find("##{identifier}").value
      expect(field_value).to eq(value)
    end

    def wait_for_element_to_load(elem)
      wait_until {page.find("##{elem}").visible? }
    end

    def get_patient_id_text
      return find('legend.mylegend span strong',:match => :first).text
    end

    def verify_start_visit_button
      expect(page).to have_button('Start OPD visit')
    end
end