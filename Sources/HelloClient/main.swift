// Copyright (C) 2016. Huawei Technologies Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftGRPC

// The main program is wrapped in a function so that ARC can have a chance to
// deinitialize class instances and free their underlying C resources.
func main() { 
    let channel = GRPCChannel(to: "0.0.0.0:50051")

    print("Testing synchronous unary call\n")

    let method = GRPCMethod(type: .NORMAL_RPC, name: "/helloworld.Greeter/SayHello")

    let context = GRPCContext(channel: channel)

    // Currently, the built-in serializer is a simple copier, so we have to prepend the protobuf header.
    let messageText = "\u{0A}\u{05}Swift" 
    let message = messageText.withCString {
        return GRPCMessage(copyFrom: $0, length: messageText.characters.count)
    }

    let (_, response) = grpcUnaryBlockingCall(channel: channel, method: method, context: context, request: message)

    // Currently, the built-in deserializer is a simple copier, so we have to extract the (unterminated) payload.
    if let okResponse = response {
        let responseData = okResponse.payload.advanced(by: 2)
        let responseLength = okResponse.length
        let rawBytes = UnsafeBufferPointer<CChar>(start: responseData, count: responseLength - 2)
        let responseText = String(cString: Array(rawBytes) + [ 0 ])

        print("Server replied: \(responseText)")
    } else {
        print("Server did not reply, or something went wrong.")
    }
}

main()
