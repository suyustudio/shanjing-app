.class public final synthetic Lz/c;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lz/d$a;


# direct methods
.method public synthetic constructor <init>(Lz/d$a;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lz/c;->d:Lz/d$a;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 1

    iget-object v0, p0, Lz/c;->d:Lz/d$a;

    invoke-static {v0}, Lz/d$a;->a(Lz/d$a;)V

    return-void
.end method
