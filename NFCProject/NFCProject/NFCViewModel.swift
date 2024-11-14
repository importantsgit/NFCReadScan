//
//  NFCViewModel.swift
//  NFCProject
//
//  Created by Importants on 11/14/24.
//

import SwiftUI
import CoreNFC

final class NFCViewModel: NSObject, ObservableObject {
    /*
     NFCNDEFReaderSession
     NDEF(NFC Data Exchange Format) 포맷 데이터 읽기/쓰기
     URL, 텍스트 등 표준화된 데이터 처리에 사용


     NFCTagReaderSession
     Raw NFC 태그 데이터 직접 읽기
     더 낮은 레벨의 태그 통신 가능
     특수 포맷이나 비표준 데이터 처리에 유용


     NFCVASReaderSession
     Value Added Service 처리 전용
     교통카드, 결제 등 특수 서비스용
     가장 제한적인 용도
     */
    
    var session: NFCNDEFReaderSession?

    func beginScanning() {
        guard NFCReaderSession.readingAvailable
        else { return }
        
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: DispatchQueue.global(),
            // 첫 태그를 읽은 후에도 세션 유지할 것인지
            invalidateAfterFirstRead: false
        )
        session?.alertMessage = "핸드폰을 꽉 잡고 있으라구~"
        session?.begin() // Session 시작
    }
}

extension NFCViewModel: NFCNDEFReaderSessionDelegate {
    // end Scanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        if let readerError = error as? NFCReaderError {
            if readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead &&
               readerError.code != .readerSessionInvalidationErrorUserCanceled {
            }
        }
        
        // 새로운 태그를 읽고 싶다면, 새로운 세션을 준비하세요!
        self.session = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("message")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard tags.count > 1,
              let tag = tags.first
        else {
            print("태그 개수: \(tags.count)")
            return
        }
        Task {
            do {
                try await session.connect(to: tag)
                let (status, capacity) = try await tag.queryNDEFStatus()
                let message = try await tag.readNDEF()
                
                MainActor.run {
                    print()
                }
            }
            catch {
                print("session connect error: \(error)")
            }
            
        }
        
    }
}
