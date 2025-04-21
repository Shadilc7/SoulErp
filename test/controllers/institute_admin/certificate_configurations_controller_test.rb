require "test_helper"

class InstituteAdmin::CertificateConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get institute_admin_certificate_configurations_index_url
    assert_response :success
  end

  test "should get new" do
    get institute_admin_certificate_configurations_new_url
    assert_response :success
  end

  test "should get create" do
    get institute_admin_certificate_configurations_create_url
    assert_response :success
  end

  test "should get edit" do
    get institute_admin_certificate_configurations_edit_url
    assert_response :success
  end

  test "should get update" do
    get institute_admin_certificate_configurations_update_url
    assert_response :success
  end

  test "should get destroy" do
    get institute_admin_certificate_configurations_destroy_url
    assert_response :success
  end
end
