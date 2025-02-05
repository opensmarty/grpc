#!/bin/bash

# Copyright 2016 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# REQUIRES: Bazel
set -ex

pushd third_party/protobuf
bazel build :protoc
PROTOC=$PWD/bazel-bin/protoc
popd

pushd third_party/upb
bazel build :protoc-gen-upb
UPB_PLUGIN=$PWD/bazel-bin/protoc-gen-upb
popd

UPB_OUTPUT_DIR=$PWD/src/core/ext/upb-generated
rm -rf $UPB_OUTPUT_DIR
mkdir $UPB_OUTPUT_DIR

proto_files=( \
  "envoy/api/v2/auth/cert.proto" \
  "envoy/api/v2/cds.proto" \
  "envoy/api/v2/cluster/circuit_breaker.proto" \
  "envoy/api/v2/cluster/outlier_detection.proto" \
  "envoy/api/v2/core/address.proto" \
  "envoy/api/v2/core/base.proto" \
  "envoy/api/v2/core/config_source.proto" \
  "envoy/api/v2/core/grpc_service.proto" \
  "envoy/api/v2/core/health_check.proto" \
  "envoy/api/v2/core/protocol.proto" \
  "envoy/api/v2/discovery.proto" \
  "envoy/api/v2/eds.proto" \
  "envoy/api/v2/endpoint/endpoint.proto" \
  "envoy/api/v2/endpoint/load_report.proto" \
  "envoy/service/discovery/v2/ads.proto" \
  "envoy/service/load_stats/v2/lrs.proto" \
  "envoy/type/percent.proto" \
  "envoy/type/range.proto" \
  "gogoproto/gogo.proto" \
  "google/api/annotations.proto" \
  "google/api/http.proto" \
  "google/protobuf/any.proto" \
  "google/protobuf/descriptor.proto" \
  "google/protobuf/duration.proto" \
  "google/protobuf/empty.proto" \
  "google/protobuf/struct.proto" \
  "google/protobuf/timestamp.proto" \
  "google/protobuf/wrappers.proto" \
  "google/rpc/status.proto" \
  "grpc/gcp/altscontext.proto" \
  "grpc/gcp/handshaker.proto" \
  "grpc/gcp/transport_security_common.proto" \
  "grpc/health/v1/health.proto" \
  "grpc/lb/v1/load_balancer.proto" \
  "validate/validate.proto")

for i in "${proto_files[@]}"
do
  $PROTOC \
    -I=$PWD/third_party/envoy-api \
    -I=$PWD/third_party/googleapis \
    -I=$PWD/third_party/protobuf/src \
    -I=$PWD/third_party/protoc-gen-validate \
    -I=$PWD/src/proto \
    -I=$PWD \
    $i \
    --upb_out=$UPB_OUTPUT_DIR \
    --plugin=protoc-gen-upb=$UPB_PLUGIN
done

find $UPB_OUTPUT_DIR -name "*.upbdefs.c" -type f -delete
find $UPB_OUTPUT_DIR -name "*.upbdefs.h" -type f -delete
