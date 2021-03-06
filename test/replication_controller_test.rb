require 'minitest/autorun'
require 'webmock/minitest'
require './lib/kubeclient'
require 'kubeclient/replication_controller'
require 'json'

class ReplicationControllerTest < MiniTest::Test

  def test_get_from_json
    json_response = "{\n  \"kind\": \"ReplicationController\",\n  \"id\": \"frontendController\",\n  \"uid\": \"f4e5966c-8eb2-11e4-a6e7-3c970e4a436a\",\n  \"creationTimestamp\": \"2014-12-28T18:59:59+02:00\",\n  \"selfLink\": \"/api/v1beta1/replicationControllers/frontendController?namespace=default\",\n  \"resourceVersion\": 11,\n  \"apiVersion\": \"v1beta1\",\n  \"namespace\": \"default\",\n  \"desiredState\": {\n    \"replicas\": 3,\n    \"replicaSelector\": {\n      \"name\": \"frontend\"\n    },\n    \"podTemplate\": {\n      \"desiredState\": {\n        \"manifest\": {\n          \"version\": \"v1beta2\",\n          \"id\": \"\",\n          \"volumes\": null,\n          \"containers\": [\n            {\n              \"name\": \"php-redis\",\n              \"image\": \"brendanburns/php-redis\",\n              \"ports\": [\n                {\n                  \"hostPort\": 8000,\n                  \"containerPort\": 80,\n                  \"protocol\": \"TCP\"\n                }\n              ],\n              \"imagePullPolicy\": \"\"\n            }\n          ],\n          \"restartPolicy\": {\n            \"always\": {}\n          }\n        }\n      },\n      \"labels\": {\n        \"name\": \"frontend\"\n      }\n    }\n  },\n  \"currentState\": {\n    \"replicas\": 3,\n    \"podTemplate\": {\n      \"desiredState\": {\n        \"manifest\": {\n          \"version\": \"\",\n          \"id\": \"\",\n          \"volumes\": null,\n          \"containers\": null,\n          \"restartPolicy\": {}\n        }\n      }\n    }\n  },\n  \"labels\": {\n    \"name\": \"frontend\"\n  }\n}"
    stub_request(:get, /.*replicationControllers*/).
        to_return(:body => json_response, :status => 200)

    client = Kubeclient::Client.new 'http://localhost:8080/api/' , "v1beta1"
    rc = client.get_replication_controller "frontendController"

    assert_instance_of(ReplicationController,rc)
    assert_equal("frontendController",rc.id)
    assert_equal("f4e5966c-8eb2-11e4-a6e7-3c970e4a436a",rc.uid)
    assert_equal("default",rc.namespace)
    assert_equal(3,rc.desired_state.replicas)
    assert_equal("frontend",rc.desired_state.replica_selector.name)
    #the access to containers is not as nice as rest of the properties, but it's about to change in beta v3,
    #hence it can significantly impact the design of the client. to be revisited after beta v3 api is released.
    assert_equal("php-redis",rc.desired_state.pod_template.desired_state.manifest.containers[0]['name'])
  end
end