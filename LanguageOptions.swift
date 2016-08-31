//
//  LanguageOptions.swift
//  Slexie
//
//  Created by Zafer Cavdar on 26/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

var preferredLanguage = Language.English

enum Language {
    
    case Turkish
    case English
    case Russian
    
    var NavBarNewsfeed: String {
        switch self {
        case .Turkish:
            return "Haber Kaynağı"
        case .English:
            return "Newsfeed"
        case .Russian:
            return "Новостная лента"
        }
    }
    
    var NavBarSearch: String {
        switch self {
        case .Turkish:
            return "Ara"
        case .English:
            return "Search"
        case .Russian:
            return "Поиск"
        }
    }
    
    var NavBarTags: String {
        switch self {
        case .Turkish:
            return "Etiketler"
        case .English:
            return "Tags"
        case .Russian:
            return "Теги"
        }
    }
    
    var NavBarNotifications: String {
        switch self {
        case .Turkish:
            return "Bildirimler"
        case .English:
            return "Notifications"
        case .Russian:
            return "Уведомления"
        }
    }
    
    var NavBarProfile: String {
        switch self {
        case .Turkish:
            return "Profil"
        case .English:
            return "Profile"
        case .Russian:
            return "Профиль"
        }
    }
    
    var NavBarLogOut: String {
        switch self {
        case .Turkish:
            return "Çıkış yap"
        case .English:
            return "Log out"
        case .Russian:
            return "Выйти"
        }
    }
    
    var TabBarHome: String {
        switch self {
        case .Turkish:
            return "Anasayfa"
        case .English:
            return "Home"
        case .Russian:
            return "Главная"
        }
    }
    
    var TabBarSearch: String {
        switch self {
        case .Turkish:
            return "Ara"
        case .English:
            return "Search"
        case .Russian:
            return "Поиск"
        }
    }
    
    var TabBarCamera: String {
        switch self {
        case .Turkish:
            return "Kamera"
        case .English:
            return "Camera"
        case .Russian:
            return "камера"
        }
    }
    
    var TabBarNotifications: String {
        switch self {
        case .Turkish:
            return "Bildirimler"
        case .English:
            return "Notifications"
        case .Russian:
            return "Уведомления"
        }
    }
    
    var TabBarProfile: String {
        switch  self {
        case .Turkish:
            return "Profil"
        case .English:
            return "Profile"
        case .Russian:
            return "Профиль"
        }
    }
    
    var LoginButton: String {
        switch self {
        case .Turkish:
            return "Giriş Yap"
        case .English:
            return "Login"
        case .Russian:
            return "Авторизоваться"
        }
    }
    
    var SignUpRedirect: String {
        switch self {
        case .Turkish:
            return "Hesabın yok mu? Kayıt ol."
        case .English:
            return "Don't you have an account? Create one."
        case .Russian:
            return "У вас нет аккаунта ? Зарегистрироваться"
        }
    }
    
    var RefreshingInfo: String {
        switch self {
        case .Turkish:
            return "Yükleniyor"
        case .English:
            return "Loading"
        case .Russian:
            return "загрузка"
        }
    }
    
    var SigningInInfo: String {
        switch self {
        case .English:
            return "Please wait"
        case .Turkish:
            return "Lütfen bekleyin"
        case .Russian:
            return "Пожалуйста, подождите!"
        }
    }
    
    var SigningUpInfo: String {
        switch self {
        case .English:
            return "Please wait"
        case .Turkish:
            return "Lütfen bekleyin"
        case .Russian:
            return "Пожалуйста, подождите!"
        }
    }
    
    var LoginScreenUsernameLabel: String {
        switch self {
        case .Turkish:
            return "Kullanıcı adı"
        case .English:
            return "Username"
        case .Russian:
            return "Имя пользователя"
        }
    }
    
    var LoginScreenPasswordLabel: String {
        switch self {
        case .Turkish:
            return "Şifre"
        case .English:
            return "Password"
        case .Russian:
            return "Пароль"
        }
    }
    
    var SignUpScreenUsernameLabel: String {
        switch self {
        case .Turkish:
            return "Benzersiz bir kullanıcı adı gir"
        case .English:
            return "Type a unique username"
        case .Russian:
            return "Введите уникальное имя пользователя"
        }
    }
    
    var SignUpScreenPasswordLabel: String {
        switch self {
        case .Turkish:
            return "Zor bir şifre girmeni öneririz"
        case .English:
            return "Strong passwords are recommended"
        case .Russian:
            return "Рекомендуется использовать надежные пароли"
        }
    }
    
    var SignUpScreenPasswordReTypeLabel: String {
        switch self {
        case .Turkish:
            return "Şifrenizi tekrar giriniz"
        case .English:
            return "Re-type your password"
        case .Russian:
            return "Введите свой пароль снова"
        }
    }
    
    var SignUpScreenSignUpButton: String {
        switch self {
        case .Turkish:
            return "Kayıt ol"
        case .English:
            return "Sign up"
        case .Russian:
            return "Зарегистрироваться"
        }
    }
    
    var SignUpScreenLanguageLabel: String {
        switch self {
        case .Turkish:
            return "Dil"
        case .English:
            return "Language"
        case .Russian:
            return "Язык"
        }
    }
    
    var SignUpScreenChooseLanguage: String {
        switch self {
        case .Turkish:
            return "Bir dil seç"
        case .English:
            return "Choose a language"
        case .Russian:
            return "Выберите язык"
        }
    }
    
    var Cancel: String {
        switch self {
        case .Turkish:
            return "İptal"
        case .English:
            return "Cancel"
        case .Russian:
            return "Отмена"
        }
    }
    
    var Public: String {
        switch self {
        case .Turkish:
            return "Açık"
        case .English:
            return "Public"
        case .Russian:
            return "Общественный"
        }
    }
    
    var Private: String {
        switch self {
        case .Turkish:
            return "Gizli"
        case .English:
            return "Private"
        case .Russian:
            return "Личный"
        }
    }
    
    var YourProfile: String {
        switch self {
        case .Turkish:
            return "Profilin: "
        case .English:
            return "Your profile: "
        case .Russian:
            return "Ваш профиль: "
        }
    }

    var UploadingInfo: String {
        switch self {
        case .Turkish:
            return "Yükleniyor"
        case .English:
            return "Uploading"
        case .Russian:
            return "Выгрузка"
        }
    }

    var AnalyzingInfo: String {
        switch self {
        case .Turkish:
            return "Analiz ediliyor"
        case .English:
            return "Analyzing"
        case .Russian:
            return "Анализ."
        }
    }

    var NotifyLikeAction: String {
        switch self {
        case .Turkish:
            return " fotoğrafını beğendi."
        case .English:
            return " has liked your photo."
        case .Russian:
            return " любил свою фотографию."
        }
    }
    
    var NotifyCommentAction: String {
        switch self {
        case .Turkish:
            return " fotoğrafına yorum yaptı."
        case .English:
            return " has commented on your photo."
        case .Russian:
            return " прокомментировал вашу фотографию."
        }
    }


}