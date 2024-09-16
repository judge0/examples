import com.google.gson.Gson;

class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    @Override
    public String toString() {
        return "Person{name='" + name + "', age=" + age + "}";
    }
}


public class Main {
    public static void main(String[] args) {
        Gson gson = new Gson();

        Person person = new Person("Nenad", 30);

        String json = gson.toJson(person);
        System.out.println("Serialized JSON: " + json);

        Person personFromJson = gson.fromJson(json, Person.class);
        System.out.println("Deserialized Object: " + personFromJson);
    }
}
