# JoSQL = NoSQL in MySQL

# JoSQL = NoSQL in MySQL
> <b>Jo</b> stands for <b>JSON object</b>.

This library helps to organize NoSQL data (to be correct: JSON string) into MySQL columns.

<b>Why MySQL</b>

* MySQL is familiar with a lot of tools and tweaks around.
* Matured and well-structured.
* Well-developed in Rails and other libraries.

<b>Why NoSQL</b>

* Data is organized with a lot of freedom. Don't need to worry about column size or truncated data.
* Access time is faster than MySQL in general.

<b>Why JoSQL</b>

* Like NoSQL, you can get all complex data in 1 query (with a good database design).
* Like NoSQL, any kind of data: array, hash, i18n can be added or removed as easy as changing a text file.
* All MySQL's benefits.

<b>Why NoJoSQL</b>

* When you decide to index 1 column it would be very slow. You need to transfer data from Jo field to normal MySQL field (again, database design is very important).
* Your JSON string can be larger than the size of MySQL column, resulting in a truncated string and loss of data.

> <b>Note:</b> This library is inspired by [[FriendlyORM|http://friendlyorm.com/]]. You can read more about the motives of building this kind of library from that page.

# 1. Install

Currently you can install it as a plugin. It only supports Rails.

```sh
./script/plugin install git://github.com/phungleson/jo.git
```

# 2. Basics

> <b>Rule of thumb:</b>

1. Create MySQL columns and index them in MySQL for all fields you want to search.
2. Put all other fields into Jo model.

> <b>Note:</b> The MySQL column that links to Jo model should be a text column.

> <b>Note:</b> Do not forget to turn on UTF-8 in both MySQL and Ruby if you want to store multi-language information.

Create your Jo model.

```ruby
class Details < Jo
  attribute :title
  attribute :body
end
```

Link your Jo model to a column Model.

```ruby
class Post < ActiveRecord::Base
  include Jonize

  jonize :details, Details
end
```

> <b>Note:</b> the name of the column (:details) can be different from the name of the Jo model (Details).

Now, you can.

```ruby
p = Post.new
p.details.title = "My first post."
p.details.body = "It is very simple to add a jo to your current AR model!"
p.save
```

Or faster this way.

```ruby
p.details = { :title => "My first post.", :body => "It is very simple to add a jo to your current AR model!" }
```

# 3. More fun

## 3.1. Custom data type

Default data type is String, but you can specify other data type. Most common (tested) ones are Fixnum, Float, Date, Time.

```ruby
class Details < Jo
  attribute :description
  attribute :url

  attribute :likes_count, Fixnum
  attribute :created_at, Time
end
```

Now, you must put in correct type.

```ruby
p.details.likes_count = "10"
```

The above code will raise an ArgumentError exception.

## 3.2. More complex Jo model (a.k.a. jo in jo)

Define a new Jo model.

```ruby
class Image < Jo
  attribute :description
  attribute :url
end
```

Put it into another Jo model.

```ruby
class Details < Jo
  attribute :title
  attribute :body
  attribute :image, Image
end
```

Now, you can.

```ruby
p.details.image = { :description => "GitHub logo", :url => "http://www.github.com/images/modules/header/logov3-hover.png" }
p.save
# Easily access complex object.
puts p.details.image.description
```

## 3.3. Array in Jo model

Create an array attribute in your Jo model.

```ruby
class Details < Jo
  attribute :title
  attribute :body
  has_many :images, Image
end
```

Now, you can.

```ruby
p.details.images << Image.new({ :description => "GitHub logo", :url => "http://www.github.com/images/modules/header/logov3-hover.png" })
p.save
# Normal loop and inspection just like an array. Actually it is a class inherited from Array.
p.details.images.each { |image| p image.description }
```

## 3.4. I18n attribute

Create an i18n attribute in your Jo model. For example details of a location table can be organized like this.

```ruby
class Details < Jo
  attribute_i18n :name
  attribute_i18n :wiki_description
end

class Location < ActiveRecord::Base
  include Jonize

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
# If the attribute doesn't have any information with your current I18n.locale, you will get :en description.
# For example, your I18n.locale == :zh-cn and location.details.name_zh_cn.blank?, you will get location.details.name_en with the following code.
<%= location.details.name_i18n %>
```

> <b>Note:</b> Add or remove locales in Jocale class if you wish to have more or less locales.

## 3.5. Validation

For example, :title of all posts must be non-blank, and :likes_count must be non-negative.

```ruby
class Details < Jo
  attribute :title, :validation => Proc.new { |v| !v.blank? }
  attribute :likes_count, Fixnum, :validation => Proc.new { |v| v >= 0 }
end
```
