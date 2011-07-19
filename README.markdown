# JoSQL = NoSQL in MySQL

> <b>Jo</b> stands for <b>JSON object</b>.

This library helps to organize NoSQL data (to be correct: JSON string) into MySQL columns.

<b>Why MySQL</b>

* MySQL is powerful when it comes to data that requires high consistency and persistence.
* Many well-developed and time-tested Ruby libraries.

<b>Why NoSQL</b>

* NoSQL is powerful with all simple design mindset.
* Data is organized with freedom. Don't need to worry about column size or truncated data.
* Read and write is known to be faster than MySQL in general.
* In some case (e.g. MongoDB, Redis), atomic actions can be done very nicely.

<b>Why JoSQL</b>

* Like NoSQL, you can get all complex data in 1 query, no joins is needed.
* Like NoSQL, a lot of freedom of data design: array, hash, i18n can be added or removed as easy as changing a text file.
* All MySQL's benefits. It is basically MySQL.

<b>Why NoJoSQL</b>

* When you decide to index 1 column it would be very slow. First, you need to transfer data from the big text field to normal MySQL field (database design is still very important). Second, index the newly added field.
* Your JSON string can be larger than the size of MySQL column, resulting in a truncated string and loss of data.

> <b>Note:</b> This library is inspired by http://friendlyorm.com/.

# 1. Install

Install in your Gemfile, the quick and dirty way.

```sh
gem 'jo', :git => 'git://github.com/phungleson/jo.git', :ref => 'bc8eddd73c1177f88206', :require => 'jo'
```

# 2. Basics

> <b>Rule of thumb:</b>

1. Create MySQL columns and index them in MySQL for all fields you want to search.
2. Put all other fields into one or many MySQL text columns by marshaling into a JSON string.

> <b>Note:</b> The MySQL column to store JSON should be a text column, or even better mediumtext.

> <b>Note:</b> Do not forget to turn on UTF-8 in both MySQL and Ruby if you want to store multi-language information.

Create your Jo model.

```ruby
class Details < Jo::Base
  attribute :title
  attribute :body
end
```

Link your Jo model to a column .

```ruby
class Post < ActiveRecord::Base
  include Jo::ActiveRecord

  jonize :details, Details
end
```

> <b>Note:</b> the name of the column (:details) can be different from the name of the Jo model (Details).

Now, you can.

```ruby
post = Post.new
post.details.title = "My first post."
post.details.body = "It is very simple to add a jo to your current AR model!"
post.save
```

Or faster this way.

```ruby
post.details = { :title => "My first post.", :body => "It is very simple to add a jo to your current AR model!" }
```

Or nicer this way.

```ruby
post.details = Details.new(:title => "My first post.", :body => "It is very simple to add a jo to your current AR model!")
```

# 3. More fun

## 3.1. Custom data type

Default data type is String, but you can specify other data type. Most common (tested) ones are :integer, :float, :date, :time.

```ruby
class Details < Jo
  attribute :description
  attribute :url

  attribute :likes_count, :integer
  attribute :created_at, :time
end
```

Now, you can put the data in.

```ruby
post.details.likes_count = "10"

p post.details.likes_count
```

## 3.2. More complex Jo model (a.k.a. jo in jo)

Define a new Jo model.

```ruby
class Image < Jo::Base
  attribute :description
  attribute :url
end
```

Put it into another Jo model.

```ruby
class Details < Jo::Base
  attribute :title
  attribute :body
  attribute :image, Image
end
```

Now, you can.

```ruby
post.details.image = { :description => "GitHub logo", :url => "http://www.github.com/images/modules/header/logov3-hover.png" }
post.save

# Now you can easily access complex object.
puts post.details.image.description
```

## 3.3. You can even put an array in Jo model

Create an array attribute in your Jo model.

```ruby
class Details < Jo::Base
  attribute :title
  attribute :body
  has_many :images, Image
end
```

Now, you can.

```ruby
post.details.images << Image.new(:description => "GitHub logo", :url => "http://www.github.com/images/modules/header/logov3-hover.png")
post.save

# Normal loop and inspection just like an array. It is essentially a class inherited from Array.
post.details.images.each { |image| p image.description }
```

## 3.4. Even more fun, you can manage your i18n attributes easily

Create an i18n attribute in your Jo model. For example details of a location table can be organized like this.

```ruby
class Details < Jo::Base
  attribute_i18n :name
  attribute_i18n :wiki_description
end

class Location < ActiveRecord::Base
  include Jo::ActiveRecord

  jonize :details, Details
end
```

Now, you can.

```ruby
location.details.name_en = "United States"
location.details.wiki_description_en = "The United States of America (also referred to as the United States, the U.S., the USA, the States, or America) is a federal constitutional republic comprising fifty states and a federal district."

location.details.name_ja = "アメリカ合衆国"
location.details.wiki_description_ja = "アメリカ合衆国（アメリカがっしゅうこく、英語: United States of America）、通称アメリカは、北アメリカ大陸および北太平洋に位置する連邦共和国。"

# If you are using Rails. You can get information of the attribute based on your current I18n.locale.
# If the attribute doesn't have any information with your current I18n.locale, you will fallback to :en description.
# For example, your I18n.locale == :zh-cn and location.details.name_zh_cn.blank?, you will get location.details.name_en with the following code.
<%= p location.details.name_i18n %>
```

> <b>Note:</b> Add or remove locales in Jo::Locale class if you wish to have more or less locales.

## 3.5. Validation

You can do all validation tricks you would normally do with ActiveSupport
