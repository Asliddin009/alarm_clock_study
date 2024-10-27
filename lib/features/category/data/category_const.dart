import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';

final List<CategoryEntity> baseListCategory = [
  CategoryEntity(
    name: 'Для разработчиков',
    id: 1,
    wordList: [
      WordEntity(
        ruWord: 'Разработчик',
        enWord: 'Developer',
        examplesRu: ['Разработчик создает приложения'],
        examplesEn: ['Developer creates applications'],
      ),
      WordEntity(
        ruWord: 'Программист',
        enWord: 'Programmer',
        examplesRu: ['Программист пишет код'],
        examplesEn: ['Programmer writes code'],
      ),
      WordEntity(
        ruWord: 'Код',
        enWord: 'Code',
        examplesRu: ['Код - это набор инструкций'],
        examplesEn: ['Code is a set of instructions'],
      ),
      WordEntity(
        ruWord: 'Приложение',
        enWord: 'Application',
        examplesRu: ['Приложение - это программа'],
        examplesEn: ['Application is a program'],
      ),
      WordEntity(
        ruWord: 'Интерфейс',
        enWord: 'Interface',
        examplesRu: ['Интерфейс - это то, что видит пользователь'],
        examplesEn: ['Interface is what the user sees'],
      ),
      WordEntity(
        ruWord: 'Функция',
        enWord: 'Function',
        examplesRu: ['Функция - это блок кода'],
        examplesEn: ['Function is a block of code'],
      ),
      WordEntity(
        ruWord: 'Переменная',
        enWord: 'Variable',
        examplesRu: ['Переменная - это место для хранения данных'],
        examplesEn: ['Variable is a place to store data'],
      ),
      WordEntity(
        ruWord: 'Цикл',
        enWord: 'Loop',
        examplesRu: ['Цикл - это повторение кода'],
        examplesEn: ['Loop is a repetition of code'],
      ),
      WordEntity(
        ruWord: 'Условие',
        enWord: 'Condition',
        examplesRu: ['Условие - это проверка'],
        examplesEn: ['Condition is a check'],
      ),
      WordEntity(
        ruWord: 'База данных',
        enWord: 'Database',
        examplesRu: ['База данных - это хранилище данных'],
        examplesEn: ['Database is a data store'],
      ),
    ],
  ),
  CategoryEntity(
    name: 'Глаголы',
    id: 2,
    wordList: [
      WordEntity(
        ruWord: 'Изучать',
        enWord: 'Learn',
        examplesRu: ['Я изучаю английский язык'],
        examplesEn: ['I learn English'],
      ),
      WordEntity(
        ruWord: 'Говорить',
        enWord: 'Speak',
        examplesRu: ['Я говорю по-английски'],
        examplesEn: ['I speak English'],
      ),
      WordEntity(
        ruWord: 'Читать',
        enWord: 'Read',
        examplesRu: ['Я читаю книги на английском'],
        examplesEn: ['I read books in English'],
      ),
      WordEntity(
        ruWord: 'Писать',
        enWord: 'Write',
        examplesRu: ['Я пишу письма на английском'],
        examplesEn: ['I write letters in English'],
      ),
      WordEntity(
        ruWord: 'Слушать',
        enWord: 'Listen',
        examplesRu: ['Я слушаю музыку на английском'],
        examplesEn: ['I listen to music in English'],
      ),
      WordEntity(
        ruWord: 'Смотреть',
        enWord: 'Watch',
        examplesRu: ['Я смотрю фильмы на английском'],
        examplesEn: ['I watch movies in English'],
      ),
      WordEntity(
        ruWord: 'Ходить',
        enWord: 'Walk',
        examplesRu: ['Я хожу на прогулки'],
        examplesEn: ['I walk for walks'],
      ),
      WordEntity(
        ruWord: 'Есть',
        enWord: 'Eat',
        examplesRu: ['Я ем завтрак'],
        examplesEn: ['I eat breakfast'],
      ),
      WordEntity(
        ruWord: 'Пить',
        enWord: 'Drink',
        examplesRu: ['Я пью воду'],
        examplesEn: ['I drink water'],
      ),
      WordEntity(
        ruWord: 'Спать',
        enWord: 'Sleep',
        examplesRu: ['Я сплю 8 часов'],
        examplesEn: ['I sleep 8 hours'],
      ),
    ],
  ),
  CategoryEntity(
    id: 3,
    name: 'топ 100 слов',
    wordList: [
      WordEntity(
        ruWord: 'Я',
        enWord: 'I',
        examplesRu: ['Я люблю английский язык'],
        examplesEn: ['I love English'],
      ),
      WordEntity(
        ruWord: 'Ты',
        enWord: 'You',
        examplesRu: ['Ты говоришь по-английски?'],
        examplesEn: ['Do you speak English?'],
      ),
      WordEntity(
        ruWord: 'Он',
        enWord: 'He',
        examplesRu: ['Он говорит по-английски'],
        examplesEn: ['He speaks English'],
      ),
      WordEntity(
        ruWord: 'Она',
        enWord: 'She',
        examplesRu: ['Она говорит по-английски'],
        examplesEn: ['She speaks English'],
      ),
      WordEntity(
        ruWord: 'Мы',
        enWord: 'We',
        examplesRu: ['Мы говорим по-английски'],
        examplesEn: ['We speak English'],
      ),
      WordEntity(
        ruWord: 'Вы',
        enWord: 'You',
        examplesRu: ['Вы говорите по-английски?'],
        examplesEn: ['Do you speak English?'],
      ),
      WordEntity(
        ruWord: 'Они',
        enWord: 'They',
        examplesRu: ['Они говорят по-английски'],
        examplesEn: ['They speak English'],
      ),
      WordEntity(
        ruWord: 'Это',
        enWord: 'It',
        examplesRu: ['Это книга'],
        examplesEn: ['It is a book'],
      ),
      WordEntity(
        ruWord: 'Есть',
        enWord: 'Is',
        examplesRu: ['Это есть книга'],
        examplesEn: ['It is a book'],
      ),
      WordEntity(
        ruWord: 'Не',
        enWord: 'Not',
        examplesRu: ['Это не книга'],
        examplesEn: ['It is not a book'],
      ),
    ],
  ),
];
