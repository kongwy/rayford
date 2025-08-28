//
//  Mock.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import Foundation

var mockStore = Store(appState: AppState(
    accounts: [
        Account(url: URL(string: "otpauth://totp/Example%20Co:alice%40example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example%20Co")!)!,
        Account(url: URL(string: "otpauth://totp/GitHub:weiyi.k?secret=JBSWY3DPEHPK3PXP&issuer=GitHub&algorithm=SHA256&digits=8")!)!,
        Account(url: URL(string: "otpauth://totp/AWS:prod%2Fbilling?secret=NB2W45DFOIZA====&issuer=AWS&algorithm=SHA512&period=60&digits=6")!)!,
        Account(url: URL(string: "otpauth://totp/Monash%20University:student%40example.edu?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&issuer=Monash%20University")!)!,
        Account(url: URL(string: "otpauth://hotp/Legacy%20VPN:bob?secret=JBSWY3DPEHPK3PXP&issuer=Legacy%20VPN&counter=0")!)!,
        Account(url: URL(string: "otpauth://hotp/BackOffice:ops%40example.com?secret=MFRGGZDFMZTWQ2LK&issuer=BackOffice&algorithm=SHA256&digits=8&counter=42")!)!,
        Account(url: URL(string: "otpauth://totp/Gmail%20(Work):davis.k%40company.com?secret=KRUGS4ZANFZSAYJA&issuer=Gmail")!)!,
        Account(url: URL(string: "otpauth://totp/Gmail%20(Personal):davis.k%40example.com?secret=ONSWG4TFOQ======&issuer=Gmail")!)!,
        Account(url: URL(string: "otpauth://totp/Custom%20App:user123?secret=KRSXG5A=&issuer=Custom%20App&digits=7")!)!,
    ]
))
