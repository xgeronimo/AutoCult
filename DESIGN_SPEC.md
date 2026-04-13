# AutoCult Design Specification
> Extracted from Figma: https://www.figma.com/design/kGYtY9WvjsCC0bI0d8kldv/AutoCult?node-id=8-215

## Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#34C37A` | Кнопки, активная вкладка, switch, акценты |
| Background | `#FFFFFF` | Фон экранов |
| Card/Surface | `#F4F4F6` | Карточки, поля ввода, иконочные контейнеры |
| Icon BG | `#DDDDDD` | Фон квадратных иконок категорий |
| Text Primary | `#000000` | Заголовки, основной текст |
| Text Secondary | `#888888` | Подписи, hint текст, год автомобиля |
| Text Tab Inactive | `#404040` | Неактивные вкладки навбара |
| Error | `#D41717` | Обязательные поля (*), текст ошибки |
| Modal Overlay | `rgba(0,0,0,0.4)` | Затемнение за модальным окном |
| Icons Color | `#09121F` | Цвет SVG иконок |

## Typography (SF Pro)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Page Title | 32px | Medium | "Авторизация" на auth экранах |
| Section Title (h2) | 24px | Semibold | "Главная", название авто в карточке |
| Section Subtitle | 20px | Semibold | "Прочие расходы", модальный заголовок |
| Screen Title (AppBar) | 18px | Semibold | Заголовок вверху ("Профиль", "Категория") |
| Body/Menu Item | 16px | Medium | Пункты профиля ("Уведомления") |
| Button Text | 14px | Semibold (SF Pro Display) | Текст кнопок |
| Label | 14px | Semibold (SF Pro Display) | Лейблы полей, текст категорий |
| Subtitle | 14px | Medium | Описания, подсказки (#888) |
| Caption | 12px | Medium | Год авто, email, дата |
| License Plate | 12px + 8px | Medium | Гос. номер (X788KA) + регион (198) |
| Tab Label Active | 10px | Semibold | "Главная" (зелёный #34C37A) |
| Tab Label Inactive | 10px | Medium | "Гараж", "Статистика" (#404040) |

## Spacing & Layout

- **Screen padding**: 20px horizontal
- **Card border-radius**: 12px
- **Input border-radius**: 10px
- **Button border-radius**: 12px
- **Button height**: 41px (primary), 44px (modal)
- **Input height**: 51px
- **Icon container**: 48x48px, border-radius 8px, bg #DDD
- **Icon size**: 24px inside container
- **Profile icon container**: 40x40px, border-radius 8px, bg #DDD
- **Tab bar pill**: 115x50px, border-radius 100px, bg #EDEDED (active)
- **Category card**: 164x64px, border-radius 12px, bg #F4F4F6
- **Car card**: 335x229px, border-radius 12px, bg #F4F4F6
- **Gap between category cards**: 7px horizontal, 8px vertical (grid 2x5)
- **Modal card**: border-radius 18px, bg white

## Screens

### 1. Sign In (Авторизация) — Frame "21"
- **Title**: "Авторизация" (32px, Medium), top: 68px
- **Subtitle**: "Введите вашу электронную почту и пароль для входа" (14px, #888), top: 114px
- **Fields**:
  - "Электронная почта *" → input с placeholder "example@email.com", top: 172px
  - "Пароль *" → input (password), top: 264px
- **"Забыли пароль?"** текстовая ссылка, 14px, top: 356px
- **Buttons** (bottom, top: 669px):
  - "Продолжить" — primary green (#34C37A), 335x41, radius 12
  - "Еще нет аккаунта?" — secondary gray (#969696), 335x41, radius 12
- **Error state** (Frame "23"): добавляется текст ошибки красным (#D41717) под полем пароля

### 2. Sign Up (Регистрация) — Frame "22"
- **Title**: "Регистрация" (32px), top: 68px
- **Subtitle**: "Введите вашу электронную почту и пароль для регистрации", top: 114px
- **Fields**:
  - "Электронная почта *" → input, top: 172px
  - "Пароль *" → input, top: 264px
  - "Повторите пароль *" → input, top: 356px
- **Buttons** (bottom, top: 669px):
  - "Продолжить" — primary
  - "Уже есть аккаунт?" — secondary

### 3. Forgot Password — Frame "24"
- **Back button**: arrow-left-s-line в glass-pill (44x44), left: 20px
- **Title**: "Забыли пароль?" (32px), top: 122px
- **Subtitle**: "Введите вашу электронную почту для восстановления пароля"
- **Field**: "Электронная почта *", top: 226px
- **Button**: "Продолжить" — primary, bottom

### 4. New Password — Frame "25"
- **Back button**: arrow-left-s-line
- **Title**: "Новый пароль" (32px)
- **Subtitle**: "Введите новый пароль для вашего аккаунта"
- **Fields**: "Пароль *" + "Повторите пароль *"
- **Button**: "Продолжить"

### 5. New Password Success Modal — Frame "26"
- **Overlay**: rgba(0,0,0,0.4) на весь экран
- **Modal Card**: bottom-aligned, padding 20px, border-radius 18px
  - check-line icon (42x42) в контейнере 56x60
  - Title: "Новый пароль установлен" (20px, Semibold)
  - Text: "Пройдите авторизацию с новым паролем" (14px, #888)
  - Button: "Перейти к авторизации" — primary green, 44px height, radius 10

### 6. Main Screen (Главная) — Frame "2" ✅ (полный дизайн-контекст)
- **Header**: "Главная" (24px, Semibold), left: 20px, top: 54px
- **Action buttons** (right side):
  - notification-4-line в glass-pill (44x44)
  - user-line в glass-pill (44x44)
- **Car Carousel**: 335x229px cards, swipeable
  - bg: #F4F4F6, radius 12
  - Car image: masked into rounded rect
  - Name: "Volkswagen Passat" (24px, Medium), top: 138px
  - Year: "2015" (12px, #888)
  - License plate: white bg, radius 6, "X788KA" (12px) + "198" (8px)
  - **Page dots**: 3 ellipses (6x6), gap 4px, centered at y: 359
- **"Добавить запись об обслуживании"**: green button (#34C37A), 335x41, radius 12, top: 381
- **"Прочие расходы"** title (20px, Semibold), top: 446
- **Category Grid** (2 columns, starting at y: 486):
  - Row 1: Топливо (charging-pile-fill) | Парковка (parking-fill)
  - Row 2: Штрафы (traffic-light-fill) | Платная дорога (route-fill)
  - Row 3: Мойка (drop-fill) | Средства ухода (brush-fill)
  - Row 4: Аксессуары (magic-fill) | Налоги и пошлины (bank-fill)
  - Row 5: Страхование (magic-fill) | Другое (bank-fill)
  - Each card: 164x64, radius 12, bg #F4F4F6
  - Icon: 48x48 container (radius 8, bg #DDD) + 24x24 SVG icon
  - Label: 14px Medium, to the right of icon
- **Tab Bar**: glass-morphism style bottom bar
  - 3 tabs: Гараж (home-6-fill) | Главная (roadster-fill) | Статистика (bubble-chart-fill)
  - Active tab: bg #EDEDED pill (115x50, radius 100), green text #34C37A
  - Inactive: text #404040
  - Tab labels: 10px

### 7. Main + Service Record Success Modal — Frame "31"
- Same as main screen with overlay + modal:
  - Title: "Запись добавлена" (20px)
  - Text: (confirmation text, 14px, #888)
  - Button: "Продолжить"

### 8. Main + Expense Success Modal — Frame "32"
- Same structure as Frame "31"

### 9. Garage Screen — visible in Tab Bar tabs
- Similar layout, showing list of cars
- Empty state (Frame with empty garage card):
  - Card 335x112, radius 12, bg #F4F4F6
  - Title: "Добавьте свой автомобиль" (16px)
  - Subtitle: "Отслеживайте статистику и ведите онлайн отчёт" (12px, #888)
  - Car image clipped to right side
  - Button: "Новый автомобиль" — primary, 335x41

### 10. Add Car — Frame "10" (3-step form)
- **Progress bar**: 335x4, radius, green fill (1/3 = 111.67px)
- **Back button**: arrow-left-s-line
- **Title**: "Новый автомобиль" (18px, Semibold, centered)
- **Fields**:
  - "Марка авто *" → dropdown (arrow-left-s-line rotated as chevron right), value: "Audi"
  - "Модель *" → dropdown, value: "A3 Sportback"
  - "Год выпуска *" → dropdown, value: "Выберите год выпуска"
  - "Гос. номер *" → text input, placeholder: "А000АА000"
- **Button**: "Следующий шаг" — primary, bottom
- Gap between fields: 16px

### 11. Car Details — Frame "14" (scrollable, height 1132px)
- **Back button** (left): arrow-left-s-line
- **Edit button** (right): edit-line
- **Title**: "Passat" (18px, centered)
- **Car Card**: 335x347, radius 12, bg #F4F4F6
  - Car image masked, larger (335x252)
  - Name: "Volkswagen Passat" (24px)
  - Year: "2015" (12px, #888)
  - License plate badge
  - **Stats ring** (环形图): pie chart 55x55 + "40 320 руб" (24px) + "Регулярные траты за сентябрь" (12px)
- **Документы section** (335x145, radius 12, bg #F4F4F6):
  - Title: "Документы" (20px, Semibold)
  - 4 document cards in a row: ПТС | СТС | Страховка | Добавить
  - Each: 67x48 container (radius 8, bg #DDD) with passport-fill icon (or add-line for "Добавить")
  - Labels: 12px below each
- **История обслуживания** (20px, Semibold)
  - "Добавить новую отметку" button: 335x48, bg with arrow-left-s-line rotated
  - "Сформировать отчёт" button: 335x41, bg (secondary style)
  - Service records list:
    - Each: 335x86, radius 12, bg #F4F4F6
    - Title: "ТО-3" (20px, Semibold)
    - Price: "20.000 ₽" (20px, Semibold, right-aligned)
    - Tags row: "Тех. обслуживание" | "10.12.2025" | "15000 км"
    - Each tag: pill bg white, radius 6, 12px text

### 12. Add Service Record — Frame "28"
- **Back button**: arrow-left-s-line
- **Title**: "Новая запись" (18px, centered)
- **Fields**:
  - "Название записи *" → text, value: "ТО"
  - "Стоимость" → text, value: "0 руб."
  - "Категория *" → dropdown с chevron, value: "Выберите категорию"
  - "Пробег *" → text, value: "0 км"
  - "Дата *" → text, value: "01.01.2026"
  - "Описание" → textarea (height 143px), placeholder: "Описание проведенных работ..."
- **Button**: "Добавить" — primary, bottom

### 13. Category Selection — Frame "29"
- **Back button**: arrow-left-s-line
- **Title**: "Категория" (18px, centered)
- **List**: 14 rows "Категория 1..14"
  - Each: 335x51, full-width
  - Text: 16px, left-aligned
  - arrow-right-s-line (24x24) right-aligned
  - No dividers, clean list

### 14. Add Expense — Frame "30"
- **Back button**: arrow-left-s-line
- **Title**: "Добавление расходов" (18px, centered)
- **Category icon**: 64x64, radius 12, bg #DDD + route-fill 32x32
- **Category name**: "Платная дорога" (20px, Semibold, centered)
- **Fields**:
  - "Стоимость *" → "0 руб."
  - "Дата *" → "01.01.2026"
- **Button**: "Добавить" — primary, bottom

### 15. Profile — Frame "6" ✅ (полный дизайн-контекст)
- **Back button**: arrow-left-s-line
- **Title**: "Профиль" (18px, centered)
- **Profile Card**: 335x79, radius 12, bg #F4F4F6
  - Name: "Иван" (24px, Medium)
  - Email: "ivanzolo2004@mail.ru" (12px, #888)
  - Edit button: 40x40 (radius 8, bg #DDD) + edit-fill icon, right-aligned
- **Menu items** (each 335x51, bg white, radius 12):
  - Уведомления (notification-4-fill) + Switch toggle (green)
  - Водительское удостоверение (passport-fill) + arrow-right-s-line
  - Оценить приложение (star-s-fill) + arrow-right-s-line
  - Тех. поддержка (customer-service-2-fill) + arrow-right-s-line
  - Политика конфиденциальности (file-list-3-fill) + arrow-right-s-line
  - [Hidden] Выйти из профиля (logout-box-r-fill) + arrow-right-s-line
- Menu item structure: icon (40x40, radius 8, bg #DDD) + text (16px) + chevron/switch

### 16. Notifications Settings — Frame "7"
- **Back button**: arrow-left-s-line
- **Title**: "Настройка уведомлений" (18px, centered)
- **Section**: "Предстоящие события" (20px, Semibold)
- **Event cards**: 335x194 / 335x137, radius 12, bg #F4F4F6
  - Event title: 16px Semibold
  - Date: 12px, #888
  - Description: 12px, multi-line
  - "Завершить" button: 311x41, inside card
- **Section**: "Завершенные события"
- **Button**: "Добавить событие" — primary, bottom

## Component Patterns

### Glass-pill Button (AppBar actions)
- Size: 44x44, border-radius: 296px
- Background: white with mix-blend-multiply, glass-morphism blur
- Icon: 24x24, centered in 36x36 area

### Category Card
```
┌──────────────────────┐
│ ┌────┐               │
│ │icon│  Label text    │  64px height
│ └────┘               │
└──────────────────────┘  164px width
```

### Profile Menu Item
```
┌─────────────────────────────────┐
│ ┌────┐  Menu item text      ›  │  51px height
│ │icon│                          │
│ └────┘                          │
└─────────────────────────────────┘  335px width
```

### Modal Card (Success)
```
┌─────────────────────────────┐
│         ✓ (42px)            │
│    Title (20px, bold)       │
│    Text (14px, #888)        │
│                             │
│  [ Primary Button 44px ]    │
└─────────────────────────────┘
  border-radius: 18px, bottom-aligned
```

## Icon Mapping

| Icon File | Remix Icon Name | Used In |
|-----------|----------------|---------|
| `charging-pile-fill.svg` | Map/charging-pile-fill | Топливо category |
| `parking-fill.svg` | Map/parking-fill | Парковка category |
| `traffic-light-fill.svg` | Map/traffic-light-fill | Штрафы category |
| `route-fill.svg` | Map/route-fill | Платная дорога category + expense page |
| `drop-fill.svg` | Design/drop-fill | Мойка category |
| `brush-fill.svg` | Design/brush-fill | Средства ухода category |
| `magic-fill.svg` | Design/magic-fill | Аксессуары + Страхование |
| `bank-fill.svg` | Buildings/bank-fill | Налоги и пошлины + Другое |
| `home-6-fill.svg` | Buildings/home-6-fill | Tab: Гараж |
| `roadster-fill.svg` | Map/roadster-fill | Tab: Главная |
| `bubble-chart-fill.svg` | Business/bubble-chart-fill | Tab: Статистика |
| `edit-fill.svg` | Design/edit-fill | Profile edit button |
| `edit-line.svg` | Design/edit-line | Car details edit button |
| `notification-4-fill.svg` | Media/notification-4-fill | Profile: Уведомления |
| `notification-4-line.svg` | Media/notification-4-line | AppBar bell icon |
| `passport-fill.svg` | Map/passport-fill | Profile: ВУ + Car documents |
| `star-s-fill.svg` | System/star-s-fill | Profile: Оценить |
| `customer-service-2-fill.svg` | Business/customer-service-2-fill | Profile: Тех. поддержка |
| `logout-box-r-fill.svg` | System/logout-box-r-fill | Profile: Выход |
| `file-list-3-fill.svg` | Document/file-list-3-fill | Profile: Политика |
| `user-line.svg` | User/user-line | AppBar user icon |
| `check-line.svg` | System/check-line | Success modal |
| `arrow-left-s-line.svg` | System/arrow-left-s-line | Back button + dropdown chevron |
| `arrow-right-s-line.svg` | System/arrow-right-s-line | Menu item chevron |
| `add-line.svg` | System/add-line | Add document button |

## Assets

- `assets/icons/` — 25 SVG icons (Remix Icons)
- `assets/images/car_placeholder.png` — 1024x1024 PNG car placeholder
