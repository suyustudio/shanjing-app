.class public Lt/d;
.super Lt/a;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lt/d$a;
    }
.end annotation


# instance fields
.field public final a:Lt/d$a;

.field final b:Lj0/j;


# direct methods
.method public constructor <init>(Lj0/j;Lj0/k$d;)V
    .locals 0

    invoke-direct {p0}, Lt/a;-><init>()V

    iput-object p1, p0, Lt/d;->b:Lj0/j;

    new-instance p1, Lt/d$a;

    invoke-direct {p1, p0, p2}, Lt/d$a;-><init>(Lt/d;Lj0/k$d;)V

    iput-object p1, p0, Lt/d;->a:Lt/d$a;

    return-void
.end method


# virtual methods
.method public c(Ljava/lang/String;)Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Ljava/lang/String;",
            ")TT;"
        }
    .end annotation

    iget-object v0, p0, Lt/d;->b:Lj0/j;

    invoke-virtual {v0, p1}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public i()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lt/d;->b:Lj0/j;

    iget-object v0, v0, Lj0/j;->a:Ljava/lang/String;

    return-object v0
.end method

.method public j(Ljava/lang/String;)Z
    .locals 1

    iget-object v0, p0, Lt/d;->b:Lj0/j;

    invoke-virtual {v0, p1}, Lj0/j;->c(Ljava/lang/String;)Z

    move-result p1

    return p1
.end method

.method public o()Lt/f;
    .locals 1

    iget-object v0, p0, Lt/d;->a:Lt/d$a;

    return-object v0
.end method
