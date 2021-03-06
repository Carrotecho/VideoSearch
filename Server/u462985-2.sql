-- phpMyAdmin SQL Dump
-- version 
-- http://www.phpmyadmin.net
--
-- Хост: u462985.mysql.masterhost.ru
-- Время создания: Сен 27 2016 г., 01:26
-- Версия сервера: 5.5.35
-- Версия PHP: 5.4.4-14+deb7u14

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `u462985`
--

-- --------------------------------------------------------

--
-- Структура таблицы `filesNames`
-- хранение имен файлов 
-- ID айди записи 
-- nameFile имя ресурса ( путь или локальный идентификатор ) 
-- userID айди пользователя которому принадлежит ресурс 
-- location данные о месте где создан ресурс 
-- type локальный или удаленный источник 
-- isLocalIdentifer локальный ли идентификатор в nameFile 

CREATE TABLE IF NOT EXISTS `filesNames` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `nameFile` text NOT NULL,
  `userID` int(11) NOT NULL,
  `location` text NOT NULL,
  `type` int(11) NOT NULL,
  `isLocalIdentifer` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

-- --------------------------------------------------------

--
-- Структура таблицы `frameData`
-- храним все кадры от всех пользователей из всех ресурсов а так же изображения

-- ID айди записи 
-- IDGROUP айди группы тегов из базы grouplabels
-- INDEXFRAME индекс кадра ( в случае с изображением 0 )
-- indexFile айди файла из filenames 
-- time не используется 
-- userID айди пользователя кому принадлежжит ресурс 



CREATE TABLE IF NOT EXISTS `frameData` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `IDGROUP` int(11) NOT NULL,
  `INDEXFRAME` int(11) NOT NULL,
  `indexFile` int(11) NOT NULL,
  `time` float NOT NULL,
  `userID` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=459 ;

-- --------------------------------------------------------

--
-- Структура таблицы `groupLabels`
-- группы тегов ( уникальные )
-- ID айди записи 
-- INDEXGROUP айди группы 
-- tag тег 
-- score очки тега то есть на сколько он вероятен 

CREATE TABLE IF NOT EXISTS `groupLabels` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `INDEXGROUP` int(11) NOT NULL,
  `tag` varchar(255) NOT NULL,
  `score` int(11) NOT NULL,
  UNIQUE KEY `ID` (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1199 ;

-- --------------------------------------------------------

--
-- Структура таблицы `oauth_access_tokens`
-- хранение ассестокенов пользователей 

CREATE TABLE IF NOT EXISTS `oauth_access_tokens` (
  `access_token` varchar(40) NOT NULL,
  `client_id` varchar(80) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `expires` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `scope` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`access_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oauth_authorization_codes`
-- не используется 

CREATE TABLE IF NOT EXISTS `oauth_authorization_codes` (
  `authorization_code` varchar(40) NOT NULL,
  `client_id` varchar(80) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `redirect_uri` varchar(2000) DEFAULT NULL,
  `expires` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `scope` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`authorization_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oauth_clients`
-- не используется 

CREATE TABLE IF NOT EXISTS `oauth_clients` (
  `client_id` varchar(80) NOT NULL,
  `client_secret` varchar(80) NOT NULL,
  `redirect_uri` varchar(2000) NOT NULL,
  `grant_types` varchar(80) DEFAULT NULL,
  `scope` varchar(100) DEFAULT NULL,
  `user_id` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oauth_jwt`
-- не испольщзуется

CREATE TABLE IF NOT EXISTS `oauth_jwt` (
  `client_id` varchar(80) NOT NULL,
  `subject` varchar(80) DEFAULT NULL,
  `public_key` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oauth_refresh_tokens`
-- хранение рефреш токенов пользователей 

CREATE TABLE IF NOT EXISTS `oauth_refresh_tokens` (
  `refresh_token` varchar(40) NOT NULL,
  `client_id` varchar(80) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `expires` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `scope` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`refresh_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oauth_scopes`
-- не используется

CREATE TABLE IF NOT EXISTS `oauth_scopes` (
  `scope` text,
  `is_default` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `oauth_users`
-- хранение пользователей 

CREATE TABLE IF NOT EXISTS `oauth_users` (
  `username` varchar(255) NOT NULL,
  `password` varchar(2000) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `role_id` int(11) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `uniqueGroups`
-- хранение уникальных групп по строкам 
-- ID айди записи 
-- tags теги в строке 
-- база нужна для того чтобы искать уже существубщие группы тегов дабы не добавлять такие же 

CREATE TABLE IF NOT EXISTS `uniqueGroups` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `tags` text NOT NULL,
  UNIQUE KEY `ID` (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=306 ;

-- --------------------------------------------------------

--
-- Структура таблицы `Users`
-- хранение пользователей 

CREATE TABLE IF NOT EXISTS `Users` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
