# Paradata

Paradata is a particular kind of metadata that represents how an
'actor' (people, organization, whatever) interacts and perform 'actions' with
a given resource (or 'object').

You can read more about our Paradata definition, for LR v1.0, on:
http://learningregistry.org/wp-content/uploads/2013/06/ParadataTwenty.pdf

For the remaining of this doc, we are assuming you've read the doc above,
so we can explore only the changes we are making.

## ActivityStreams 2.0

Our new implementation of paradata is based on
[ActivityStreams 2.0](https://www.w3.org/TR/activitystreams-core/).
We are using only a subset of the properties exposed by the spec,
and also adding a few others (mostly for handling aggregation and measurement info).

## Envelope

To send a paradata envelope you have to use the property:

```
"envelope_type": "paradata"
```

this is fundamental so we know how to validate and store this envelope properly.


## Schema

Below we provide a small sample of the data format. Notice that all paradata
resources should be encoded as `json-ld` and at least provide a `@context`.

```json
{
  "@context": "http://www.w3.org/ns/activitystreams",
  "name": "High school English teachers taught this resource 15 times during the month of May 2011",
  "type": "Taught",
  "actor": {
    "type": "Group",
    "name": "teacher",
    "keywords": [ "high school", "english" ]
  },
  "object": "http://URL/to/lesson",
  "measure": {
    "measureType": "count",
    "value": 15
  },
  "date": "2011-05-01/2011-05-31"
}
```

where:

- **@context** : One of the contexts provided has to be "http://www.w3.org/ns/activitystreams"
- **name** : Is a high level human-readable string that describes the activity.
- **type** : Is the type of the activity. You can provide anything you want, but if possible use one of the Activity subclasses defined on https://www.w3.org/TR/activitystreams-vocabulary/#activity-types
- **actor** : Refers to the person or group who does something. Can be either a string or a json object.
    - **type** if possible should be one of https://www.w3.org/TR/activitystreams-vocabulary/#actor-types.
    - **keywords** [extended property] Is a list of attributes that describe the actor.
- **object** : Refers to the thing being acted upon. Can be either a string or a json object.
- **measure** : [extended property] used for measurement/aggregation info.
    - **measureType** : type of the measure being displayed
    - **value** : value or magnitude of the measurement
- **date** : [extended property] used both for "point in time" activities or "time range" on aggregation/events. If it's a period of time, it contains two dates separated by a slash. This field is defined by RFC3339 and ISO8601.

We also can have:

- **target** : Provides a way of describing where the activity took place, i.e., the indirect object or target, of the activity. Examples:
    - "John added a bookmark to delicio.us", the target is "delicio.us"
    - "Lucy added a blog post", the target is the blog url.
- **related** : [extended property] Is a collection of things that relate to the paradata (usually the object). It's an array of JSON 'objects'. For example: "The document N is composed of X, Y and Z", the related is a list of "X", "Y" and "Z".
- **context** : The intended function is to serve as a means of grouping objects and activities that share a common originating context or purpose.


For more info, check the full [json-schema](/app/schemas/paradata.json.erb)


## Translating from Paradata 1.0


| paradata 1.0      | Current (ActivityStreams 2.0) |
| ----------------- | ----------------------------  |
| actor             | actor                         |
| actor/objectType  | actor/id                      |
| actor/description | actor/keywords                |
| verb              | type                          |
| verb/measure      | measure                       |
| verb/date         | date                          |
| verb/context      | target (mostly) OR context    |
| object            | object                        |
| related           | related                       |
| content           | name                          |


## Common Use Cases

### Resource access count

```json
{
  "@context": "http://www.w3.org/ns/activitystreams",
  "name": "How many people accesses this resource today",
  "type": "View",
  "object": "http://URL/to/resource",
  "measure": {
    "measureType": "count",
    "value": 1500
  },
  "date": "2016-07-20"
}
```

### Resource usage count

```json
{
  "@context": "http://www.w3.org/ns/activitystreams",
  "name": "How many people used this resource on the year of 2016",
  "type": "Use",
  "object": {
    "id": "http://URL/to/resource",
    "name": "Name for the resource",
    "image": "http://path/to/resource/display/image"
  },
  "measure": {
    "measureType": "count",
    "value": 150
  },
  "date": "2016-01-01/2016-12-31"
}
```

### Resource rating

```json
{
  "@context": "http://www.w3.org/ns/activitystreams",
  "name": "John rated 5 stars for the new star wars movie on imdb",
  "type": "Rate",
  "author": {
    "id": "http://path/to/john",
    "name": "John Doe"
  },
  "object": "http://URL/to/StarWars/the-force-awakens",
  "measure": {
    "measureType": "rate",
    "value": 5
  },
  "target": "http://imdb.com",
  "date": "2016-07-20T22:12:05"
}
```

### Resource review

```json
{
  "@context": "http://www.w3.org/ns/activitystreams",
  "name": "John reviewed the article on the news-blog",
  "type": "Review",
  "author": "http://path/to/john",
  "object": {
    "type": "Article",
    "id": "http://URL/to/article",
    "name": "Article title"
  },
  "measure": {
    "measureType": "review",
    "value": "I think blablablbala ...I want ice cream... bleble... and so forth"
  },
  "target": "http://new-blog.com/",
  "date": "2016-07-20T22:12:05"
}
```
