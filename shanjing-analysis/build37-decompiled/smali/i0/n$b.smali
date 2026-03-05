.class Li0/n$b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/k$c;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Li0/n;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Li0/n;


# direct methods
.method constructor <init>(Li0/n;)V
    .locals 0

    iput-object p1, p0, Li0/n$b;->a:Li0/n;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public h(Lj0/j;Lj0/k$d;)V
    .locals 2

    iget-object v0, p1, Lj0/j;->a:Ljava/lang/String;

    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    const-string v1, "get"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_1

    const-string v1, "put"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    invoke-interface {p2}, Lj0/k$d;->c()V

    goto :goto_2

    :cond_0
    iget-object v0, p0, Li0/n$b;->a:Li0/n;

    check-cast p1, [B

    invoke-static {v0, p1}, Li0/n;->b(Li0/n;[B)[B

    const/4 p1, 0x0

    :goto_0
    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    goto :goto_2

    :cond_1
    iget-object p1, p0, Li0/n$b;->a:Li0/n;

    const/4 v0, 0x1

    invoke-static {p1, v0}, Li0/n;->c(Li0/n;Z)Z

    iget-object p1, p0, Li0/n$b;->a:Li0/n;

    invoke-static {p1}, Li0/n;->d(Li0/n;)Z

    move-result p1

    if-nez p1, :cond_3

    iget-object p1, p0, Li0/n$b;->a:Li0/n;

    iget-boolean v0, p1, Li0/n;->a:Z

    if-nez v0, :cond_2

    goto :goto_1

    :cond_2
    invoke-static {p1, p2}, Li0/n;->f(Li0/n;Lj0/k$d;)Lj0/k$d;

    goto :goto_2

    :cond_3
    :goto_1
    iget-object p1, p0, Li0/n$b;->a:Li0/n;

    invoke-static {p1}, Li0/n;->a(Li0/n;)[B

    move-result-object v0

    invoke-static {p1, v0}, Li0/n;->e(Li0/n;[B)Ljava/util/Map;

    move-result-object p1

    goto :goto_0

    :goto_2
    return-void
.end method
