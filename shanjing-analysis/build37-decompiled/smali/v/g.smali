.class Lv/g;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/k$c;


# instance fields
.field private final a:Lv/b;


# direct methods
.method static constructor <clinit>()V
    .locals 0

    return-void
.end method

.method constructor <init>(Lv/b;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lv/g;->a:Lv/b;

    return-void
.end method


# virtual methods
.method public h(Lj0/j;Lj0/k$d;)V
    .locals 1

    iget-object p1, p1, Lj0/j;->a:Ljava/lang/String;

    const-string v0, "check"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_0

    iget-object p1, p0, Lv/g;->a:Lv/b;

    invoke-virtual {p1}, Lv/b;->b()Ljava/lang/String;

    move-result-object p1

    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    goto :goto_0

    :cond_0
    invoke-interface {p2}, Lj0/k$d;->c()V

    :goto_0
    return-void
.end method
